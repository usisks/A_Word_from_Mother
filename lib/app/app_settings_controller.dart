import 'package:flutter/foundation.dart';

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

  AppViewState get state => _state;

  Future<void> initialize() async {
    try {
      await _gateway.initialize();
      var settings = await _store.read();
      final allowed = await _gateway.areNotificationsEnabled();
      if (settings.notificationsEnabled && !allowed) {
        await _cancelBestEffort();
        settings = settings.copyWith(notificationsEnabled: false);
        await _store.write(settings);
      }
      _state = _state.copyWith(
        settings: settings,
        permission: allowed
            ? NotificationPermissionState.granted
            : NotificationPermissionState.denied,
        phase: settings.onboardingCompleted
            ? AppPhase.home
            : AppPhase.languageSelection,
      );
      notifyListeners();
      if (settings.notificationsEnabled && allowed) {
        await _refreshSchedule(rebuild: false);
      }
    } on Object catch (error, stack) {
      debugPrint('startup_failed: $error\n$stack');
      _state = _state.copyWith(
        phase: AppPhase.startupError,
        settings: AppSettings.defaults(),
        userVisibleError: 'settings_read_failed',
      );
      notifyListeners();
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
    _state = _state.copyWith(phase: AppPhase.home, settings: settings);
    notifyListeners();
  }

  Future<void> requestPermissionAndEnableNotifications() async {
    _setWorking();
    try {
      final granted = await _gateway.requestPermission();
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
      debugPrint('schedule_failed: $error\n$stack');
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
      } on Object {
        await _scheduler.cancelAll();
      }
      final settings = _state.settings.copyWith(notificationsEnabled: false);
      await _persistAndVerify(settings, expectedNotificationsEnabled: false);
      _state = _state.copyWith(
        settings: settings,
        scheduling: SchedulingState.idle,
        clearError: true,
      );
    } on Object catch (error) {
      debugPrint('cancel_failed: $error');
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
    final allowed = await _gateway.areNotificationsEnabled();
    _state = _state.copyWith(
      permission: allowed
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied,
    );
    if (!allowed && _state.settings.notificationsEnabled) {
      try {
        await _scheduler.cancelAll();
      } on Object catch (error) {
        debugPrint('cancel_after_permission_revoked_failed: $error');
      }
      final settings = _state.settings.copyWith(notificationsEnabled: false);
      await _persist(settings);
      _state = _state.copyWith(settings: settings);
    } else if (allowed && _state.settings.notificationsEnabled) {
      await _refreshSchedule(rebuild: false);
    }
    notifyListeners();
  }

  Future<void> retryScheduling() => _state.settings.notificationsEnabled
      ? _refreshSchedule(rebuild: true)
      : setNotificationsEnabled(true);
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
      debugPrint('schedule_failed: $error\n$stack');
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
      );

  Future<void> _persist(AppSettings settings) => _store.write(settings);

  Future<void> _cancelBestEffort() async {
    try {
      await _gateway.cancelAll();
    } on Object catch (error) {
      debugPrint('best_effort_cancel_failed: $error');
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
