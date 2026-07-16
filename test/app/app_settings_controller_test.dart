import 'package:a_word_from_mother/app/app_settings_controller.dart';
import 'package:a_word_from_mother/app/app_view_state.dart';
import 'package:a_word_from_mother/core/clock.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/notifications/notification_gateway.dart';
import 'package:a_word_from_mother/notifications/notification_scheduler.dart';
import 'package:a_word_from_mother/platform/time_zone_service.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _Store implements SettingsStore {
  AppSettings value = AppSettings.defaults();
  bool failRead = false;
  @override
  Future<void> clearRecentHistory() async {}
  @override
  Future<AppSettings> read() async {
    if (failRead) throw StateError('read failed');
    return value;
  }

  @override
  Future<void> write(AppSettings settings) async => value = settings;
}

class _Gateway implements NotificationGateway {
  bool permission = false;
  bool failInitialization = false;
  bool failPermissionCheck = false;
  var cancelCalls = 0;
  var initializeCalls = 0;
  @override
  Future<bool> areNotificationsEnabled() async {
    if (failPermissionCheck) throw StateError('permission check failed');
    return permission;
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
  }

  @override
  Future<void> initialize() async {
    initializeCalls++;
    if (failInitialization) throw StateError('initialization failed');
  }

  @override
  Future<void> openSystemNotificationSettings() async {}
  @override
  Future<int> pendingCount() async => 0;
  @override
  Future<bool> requestPermission() async => permission;
  @override
  Future<void> schedule(ScheduledMotherNotification notification) async {}
}

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 7, 16, 12);
}

class _Random implements RandomSource {
  @override
  int nextInt(int max) => 0;
}

AppSettingsController _controller(_Store store, _Gateway gateway) =>
    AppSettingsController(
      store: store,
      gateway: gateway,
      scheduler: NotificationScheduler(
        gateway: gateway,
        messages: const [],
        timeZoneService: TimeZoneService(),
        clock: _Clock(),
        random: _Random(),
      ),
    );

void main() {
  test(
    'first launch progresses to Home without requesting permission',
    () async {
      final store = _Store();
      final app = _controller(store, _Gateway());
      await app.initialize();
      expect(app.state.phase, AppPhase.languageSelection);
      await app.completeLanguageSelection(AppLanguage.en);
      expect(app.state.phase, AppPhase.voiceSelection);
      await app.completeVoiceSelection(MotherVoice.enBritish);
      expect(app.state.phase, AppPhase.permissionExplanation);
      await app.completeOnboardingWithoutNotifications();
      expect(app.state.phase, AppPhase.home);
      expect(store.value.onboardingCompleted, isTrue);
      expect(store.value.notificationsEnabled, isFalse);
    },
  );

  test(
    'settings read failure uses safe defaults without blocking startup',
    () async {
      final store = _Store()..failRead = true;
      final app = _controller(store, _Gateway());

      await app.initialize();

      expect(app.state.phase, AppPhase.languageSelection);
      expect(app.state.settings, AppSettings.defaults());
      expect(app.state.settings.notificationsEnabled, isFalse);
      expect(app.state.userVisibleError, 'settings_read_failed');
    },
  );

  test(
    'permission denial finishes onboarding safely with notifications off',
    () async {
      final store = _Store();
      final app = _controller(store, _Gateway());
      await app.initialize();
      await app.requestPermissionAndEnableNotifications();
      expect(app.state.phase, AppPhase.home);
      expect(app.state.permission, NotificationPermissionState.denied);
      expect(app.state.settings.notificationsEnabled, isFalse);
      expect(app.state.userVisibleError, 'permission_denied');
    },
  );

  test(
    'notification initialization failure is non-fatal and can be retried',
    () async {
      final store = _Store();
      final gateway = _Gateway()..failInitialization = true;
      final app = _controller(store, gateway);

      await app.initialize();

      expect(app.state.phase, AppPhase.languageSelection);
      expect(app.state.settings.notificationsEnabled, isFalse);
      expect(app.state.scheduling, SchedulingState.failed);
      expect(app.state.userVisibleError, 'notification_initialize_failed');

      gateway.failInitialization = false;
      await app.retryNotificationSetup();

      expect(gateway.initializeCalls, 2);
      expect(app.state.phase, AppPhase.languageSelection);
      expect(app.state.scheduling, SchedulingState.idle);
      expect(app.state.userVisibleError, isNull);
    },
  );

  test(
    'permission check failure starts home safely with notifications off',
    () async {
      final store = _Store()
        ..value = AppSettings.defaults().copyWith(
          onboardingCompleted: true,
          notificationsEnabled: true,
        );
      final gateway = _Gateway()..failPermissionCheck = true;
      final app = _controller(store, gateway);

      await app.initialize();

      expect(app.state.phase, AppPhase.home);
      expect(app.state.settings.notificationsEnabled, isFalse);
      expect(store.value.notificationsEnabled, isFalse);
      expect(app.state.permission, NotificationPermissionState.unknown);
      expect(
        app.state.userVisibleError,
        'notification_permission_check_failed',
      );

      gateway.failPermissionCheck = false;
      await app.retryNotificationSetup();

      expect(app.state.scheduling, SchedulingState.idle);
      expect(app.state.userVisibleError, isNull);
    },
  );

  test('notification enable retries gateway initialization', () async {
    final store = _Store();
    final gateway = _Gateway()..failInitialization = true;
    final app = _controller(store, gateway);
    await app.initialize();

    gateway.failInitialization = false;
    await app.requestPermissionAndEnableNotifications();

    expect(gateway.initializeCalls, 2);
    expect(app.state.phase, AppPhase.home);
    expect(app.state.settings.notificationsEnabled, isFalse);
    expect(app.state.permission, NotificationPermissionState.denied);
  });
}
