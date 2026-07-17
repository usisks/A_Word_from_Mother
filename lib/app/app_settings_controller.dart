import 'package:flutter/foundation.dart';

import '../core/diagnostics.dart';
import '../notifications/notification_gateway.dart';
import '../notifications/notification_scheduler.dart';
import '../settings/app_settings.dart';
import '../settings/settings_store.dart';
import 'app_view_state.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    required SettingsStore store,
    required NotificationGateway gateway,
    required NotificationScheduler scheduler,
  }) : this._(store, gateway, scheduler);

  AppSettingsController._(this._store, this._gateway, this._scheduler);

  final SettingsStore _store;
  final NotificationGateway _gateway;
  final NotificationScheduler _scheduler;
  AppViewState _state = AppViewState.loading();
  bool _editing = false;
  bool _notificationInitialized = false;

  AppViewState get state => _state;

  Future<void> initialize() async {
    var settings = AppSettings.defaults();
    String? startupWarning;
    try {
      settings = await _store.read();
    } on Object catch (error, stack) {
      logFailure('settings_read_failed', error, stack);
      startupWarning = 'settings_read_failed';
    }

    final initializationError = await _ensureNotificationInitialized();
    final allowed = initializationError == null
        ? await _areNotificationsEnabledSafely()
        : null;
    final notificationError =
        initializationError ??
        (allowed == null ? 'notification_permission_check_failed' : null);
    startupWarning = notificationError ?? startupWarning;

    if (settings.notificationsEnabled &&
        (notificationError != null || allowed != true)) {
      await _cancelBestEffort();
      settings = settings.copyWith(notificationsEnabled: false);
      await _persistBestEffort(settings);
    }

    _state = AppViewState(
      settings: settings,
      permission: allowed == null
          ? NotificationPermissionState.unknown
          : allowed
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied,
      phase: settings.onboardingCompleted
          ? AppPhase.home
          : AppPhase.languageSelection,
      scheduling: notificationError == null
          ? SchedulingState.idle
          : SchedulingState.failed,
      userVisibleError: startupWarning,
    );
    notifyListeners();
    if (settings.notificationsEnabled && allowed == true) {
      await _refreshSchedule(rebuild: false);
    }
  }

  Future<void> completeLanguageSelection(AppLanguage language) async {
    final settings = _state.settings.copyWith(
      language: language,
      voice: language.defaultVoice,
    );
    _state = _state.copyWith(
      phase: AppPhase.voiceSelection,
      settings: settings,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> completeVoiceSelection(MotherVoice voice) async {
    if (voice.language != _state.settings.language) {
      throw ArgumentError('Voice does not match language');
    }
    final settings = _state.settings.copyWith(voice: voice);
    await _persist(settings);
    _state = _state.copyWith(settings: settings);
    notifyListeners();
    if (_editing) {
      _editing = false;
      if (settings.notificationsEnabled) await _refreshSchedule(rebuild: true);
      _state = _state.copyWith(phase: AppPhase.home);
    } else {
      _state = _state.copyWith(phase: AppPhase.permissionExplanation);
    }
    notifyListeners();
  }

  Future<void> changeLanguage(AppLanguage language) async {
    _editing = true;
    await completeLanguageSelection(language);
  }

  Future<void> changeVoice(MotherVoice voice) async {
    if (voice.language != _state.settings.language) {
      throw ArgumentError('Voice does not match language');
    }
    final settings = _state.settings.copyWith(voice: voice);
    await _persist(settings);
    _state = _state.copyWith(settings: settings, phase: AppPhase.home);
    notifyListeners();
    if (settings.notificationsEnabled) await _refreshSchedule(rebuild: true);
  }

  Future<void> completeOnboardingWithoutNotifications() async {
    final settings = _state.settings.copyWith(
      onboardingCompleted: true,
      notificationsEnabled: false,
    );
    await _persist(settings);
    _state = _state.copyWith(
      phase: AppPhase.home,
      settings: settings,
      scheduling: SchedulingState.idle,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> requestPermissionAndEnableNotifications() async {
    _setWorking();
    final initializationError = await _ensureNotificationInitialized();
    if (initializationError != null) {
      await _disableNotificationsAfterFailure(initializationError);
      return;
    }
    final alreadyAllowed = await _areNotificationsEnabledSafely();
    if (alreadyAllowed == null) {
      await _disableNotificationsAfterFailure(
        'notification_permission_check_failed',
      );
      return;
    }
    bool granted;
    try {
      granted = alreadyAllowed || await _gateway.requestPermission();
    } on Object catch (error, stackTrace) {
      logFailure('notification_permission_request_failed', error, stackTrace);
      await _disableNotificationsAfterFailure(
        'notification_permission_request_failed',
      );
      return;
    }
    try {
      if (!granted) {
        await _cancelBestEffort();
        final settings = _state.settings.copyWith(
          onboardingCompleted: true,
          notificationsEnabled: false,
        );
        await _persist(settings);
        _state = _state.copyWith(
          phase: AppPhase.home,
          settings: settings,
          permission: NotificationPermissionState.denied,
          scheduling: SchedulingState.idle,
          userVisibleError: 'permission_denied',
        );
        notifyListeners();
        return;
      }
      _state = _state.copyWith(permission: NotificationPermissionState.granted);
      final summary = await _scheduler.rebuild(settings: _state.settings);
      final settings = _settingsAfterSchedule(
        summary,
      ).copyWith(onboardingCompleted: true, notificationsEnabled: true);
      await _persistAndVerify(settings, expectedNotificationsEnabled: true);
      _state = _state.copyWith(
        phase: AppPhase.home,
        settings: settings,
        scheduling: SchedulingState.idle,
        clearError: true,
      );
    } on Object catch (error, stack) {
      logFailure('schedule_failed', error, stack);
      await _cancelBestEffort();
      final settings = _state.settings.copyWith(
        onboardingCompleted: true,
        notificationsEnabled: false,
      );
      await _persist(settings);
      _state = _state.copyWith(
        phase: AppPhase.home,
        settings: settings,
        scheduling: SchedulingState.failed,
        userVisibleError: 'schedule_failed',
      );
    }
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_state.scheduling == SchedulingState.working) return;
    if (enabled) {
      await requestPermissionAndEnableNotifications();
      return;
    }
    _setWorking();
    try {
      try {
        await _scheduler.cancelAll();
      } on Object catch (error, stackTrace) {
        logFailure('cancel_first_attempt_failed', error, stackTrace);
        await _scheduler.cancelAll();
      }
      final settings = _state.settings.copyWith(notificationsEnabled: false);
      await _persistAndVerify(settings, expectedNotificationsEnabled: false);
      _state = _state.copyWith(
        settings: settings,
        scheduling: SchedulingState.idle,
        clearError: true,
      );
    } on Object catch (error, stackTrace) {
      logFailure('cancel_failed', error, stackTrace);
      _state = _state.copyWith(
        scheduling: SchedulingState.failed,
        userVisibleError: 'cancel_failed',
      );
    }
    notifyListeners();
  }

  void editLanguageAndVoice() {
    _editing = true;
    _state = _state.copyWith(phase: AppPhase.languageSelection);
    notifyListeners();
  }

  void backToLanguageSelection() {
    _state = _state.copyWith(phase: AppPhase.languageSelection);
    notifyListeners();
  }

  void showHomeFromNotification() {
    if (_state.settings.onboardingCompleted) {
      _editing = false;
      _state = _state.copyWith(phase: AppPhase.home);
      notifyListeners();
    }
  }

  Future<void> onAppResumed() async {
    if (_state.phase != AppPhase.home) return;
    final initializationError = await _ensureNotificationInitialized();
    if (initializationError != null) {
      await _disableNotificationsAfterFailure(
        initializationError,
        completeOnboarding: false,
      );
      return;
    }
    final allowed = await _areNotificationsEnabledSafely();
    if (allowed == null) {
      await _disableNotificationsAfterFailure(
        'notification_permission_check_failed',
        completeOnboarding: false,
      );
      return;
    }
    _state = _state.copyWith(
      permission: allowed
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied,
    );
    if (!allowed && _state.settings.notificationsEnabled) {
      try {
        await _scheduler.cancelAll();
      } on Object catch (error, stackTrace) {
        logFailure('cancel_after_permission_revoked_failed', error, stackTrace);
      }
      final settings = _state.settings.copyWith(notificationsEnabled: false);
      await _persist(settings);
      _state = _state.copyWith(settings: settings);
    } else if (allowed && _state.settings.notificationsEnabled) {
      await _refreshSchedule(rebuild: false);
    }
    notifyListeners();
  }

  Future<void> retryScheduling() => switch (_state.userVisibleError) {
    'notification_initialize_failed' ||
    'notification_permission_check_failed' => retryNotificationSetup(),
    _ =>
      _state.settings.notificationsEnabled
          ? _refreshSchedule(rebuild: true)
          : setNotificationsEnabled(true),
  };

  Future<void> retryNotificationSetup() async {
    _setWorking();
    final initializationError = await _ensureNotificationInitialized();
    if (initializationError != null) {
      await _disableNotificationsAfterFailure(
        initializationError,
        completeOnboarding: false,
      );
      return;
    }
    final allowed = await _areNotificationsEnabledSafely();
    if (allowed == null) {
      await _disableNotificationsAfterFailure(
        'notification_permission_check_failed',
        completeOnboarding: false,
      );
      return;
    }
    _state = _state.copyWith(
      permission: allowed
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied,
      scheduling: SchedulingState.idle,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> openSystemNotificationSettings() =>
      _gateway.openSystemNotificationSettings();

  void _setWorking() {
    _state = _state.copyWith(
      scheduling: SchedulingState.working,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> _refreshSchedule({required bool rebuild}) async {
    _setWorking();
    try {
      final summary = rebuild
          ? await _scheduler.rebuild(settings: _state.settings)
          : await _scheduler.ensureSchedule(settings: _state.settings);
      final settings = _settingsAfterSchedule(summary);
      await _persist(settings);
      _state = _state.copyWith(
        settings: settings,
        scheduling: SchedulingState.idle,
        clearError: true,
      );
    } on Object catch (error, stack) {
      logFailure('schedule_failed', error, stack);
      await _cancelBestEffort();
      final settings = _state.settings.copyWith(notificationsEnabled: false);
      await _persist(settings);
      _state = _state.copyWith(
        settings: settings,
        scheduling: SchedulingState.failed,
        userVisibleError: 'schedule_failed',
      );
    }
    notifyListeners();
  }

  AppSettings _settingsAfterSchedule(ScheduleSummary summary) =>
      _state.settings.copyWith(
        recentContentIds: summary.recentContentIds,
        recentCategories: summary.recentCategories,
        lastScheduleRefreshAt: DateTime.now(),
        lastTimeZoneId: summary.timeZoneId,
        scheduleVersion: summary.scheduleVersion,
      );

  Future<void> _persist(AppSettings settings) => _store.write(settings);

  Future<void> _cancelBestEffort() async {
    try {
      await _gateway.cancelAll();
    } on Object catch (error, stackTrace) {
      logFailure('best_effort_cancel_failed', error, stackTrace);
    }
  }

  Future<String?> _ensureNotificationInitialized() async {
    if (_notificationInitialized) return null;
    try {
      await _gateway.initialize();
      _notificationInitialized = true;
      return null;
    } on Object catch (error, stackTrace) {
      logFailure('notification_initialize_failed', error, stackTrace);
      return 'notification_initialize_failed';
    }
  }

  Future<bool?> _areNotificationsEnabledSafely() async {
    try {
      return await _gateway.areNotificationsEnabled();
    } on Object catch (error, stackTrace) {
      logFailure('notification_permission_check_failed', error, stackTrace);
      return null;
    }
  }

  Future<void> _disableNotificationsAfterFailure(
    String errorCode, {
    bool completeOnboarding = true,
  }) async {
    await _cancelBestEffort();
    final settings = _state.settings.copyWith(
      onboardingCompleted:
          completeOnboarding || _state.settings.onboardingCompleted,
      notificationsEnabled: false,
    );
    await _persistBestEffort(settings);
    _state = _state.copyWith(
      phase: completeOnboarding ? AppPhase.home : _state.phase,
      settings: settings,
      permission: NotificationPermissionState.unknown,
      scheduling: SchedulingState.failed,
      userVisibleError: errorCode,
    );
    notifyListeners();
  }

  Future<void> _persistBestEffort(AppSettings settings) async {
    try {
      await _persist(settings);
    } on Object catch (error, stackTrace) {
      logFailure('settings_write_failed', error, stackTrace);
    }
  }

  Future<void> _persistAndVerify(
    AppSettings settings, {
    required bool expectedNotificationsEnabled,
  }) async {
    await _store.write(settings);
    final verified = await _store.read();
    if (verified.notificationsEnabled != expectedNotificationsEnabled) {
      throw StateError('settings_write_failed');
    }
  }
}
