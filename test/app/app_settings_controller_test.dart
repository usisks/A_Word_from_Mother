import 'package:a_word_from_mother/app/app_settings_controller.dart';
import 'package:a_word_from_mother/app/app_view_state.dart';
import 'package:a_word_from_mother/content/mother_message.dart';
import 'package:a_word_from_mother/content/in_app_message_selector.dart';
import 'package:a_word_from_mother/core/clock.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/notifications/notification_gateway.dart';
import 'package:a_word_from_mother/notifications/notification_scheduler.dart';
import 'package:a_word_from_mother/platform/time_zone_service.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:a_word_from_mother/settings/notification_window.dart';
import 'package:a_word_from_mother/settings/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _Store implements SettingsStore {
  AppSettings value = AppSettings.defaults();
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<void> clearRecentHistory() async {}
  @override
  Future<AppSettings> read() async {
    if (failRead) throw StateError('read failed');
    return value;
  }

  @override
  Future<void> write(AppSettings settings) async {
    if (failWrite) throw StateError('write failed');
    value = settings;
  }
}

class _Gateway implements NotificationGateway {
  bool permission = false;
  bool failInitialization = false;
  bool failPermissionCheck = false;
  var cancelCalls = 0;
  var initializeCalls = 0;
  var scheduleCalls = 0;
  bool failSchedule = false;
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
  Future<void> schedule(ScheduledMotherNotification notification) async {
    scheduleCalls++;
    if (failSchedule) throw StateError('schedule failed');
  }
}

class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 7, 16, 12);
}

class _Random implements RandomSource {
  @override
  int nextInt(int max) => 0;
}

class _TimeZoneService extends TimeZoneService {
  @override
  Future<String> initialize() async => 'Asia/Tokyo';
}

final _messages = List<MotherMessage>.generate(MotherVoice.values.length * 31, (
  index,
) {
  final voice = MotherVoice.values[index ~/ 31];
  final sequence = index % 31;
  return MotherMessage(
    id: '${voice.value}-${sequence.toString().padLeft(4, '0')}',
    language: voice.language,
    voice: voice,
    category: MessageCategory.values[sequence % MessageCategory.values.length],
    body: 'test $index',
  );
}, growable: false);

AppSettingsController _controller(_Store store, _Gateway gateway) =>
    AppSettingsController(
      store: store,
      gateway: gateway,
      scheduler: NotificationScheduler(
        gateway: gateway,
        messages: _messages,
        timeZoneService: _TimeZoneService(),
        clock: _Clock(),
        random: _Random(),
      ),
      inAppMessageSelector: InAppMessageSelector(
        messages: _messages,
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
      expect(app.state.inAppMessage, isNotNull);
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

  test('window change while notifications are off only persists', () async {
    final store = _Store();
    final gateway = _Gateway();
    final app = _controller(store, gateway);
    await app.initialize();
    final window = NotificationWindow.tryCreate(
      startMinute: 420,
      endMinute: 1200,
    )!;

    await app.updateNotificationWindow(window);

    expect(app.state.settings.notificationWindow, same(window));
    expect(store.value.notificationWindow, same(window));
    expect(gateway.scheduleCalls, 0);
    expect(app.state.scheduling, SchedulingState.idle);
  });

  test('frequency change while notifications are on rebuilds', () async {
    final store = _Store();
    final gateway = _Gateway()..permission = true;
    final app = _controller(store, gateway);
    await app.initialize();
    await app.requestPermissionAndEnableNotifications();
    final previousScheduleCalls = gateway.scheduleCalls;

    await app.updateNotificationFrequency(NotificationFrequency.chatty);

    expect(
      app.state.settings.notificationFrequency,
      NotificationFrequency.chatty,
    );
    expect(app.state.settings.notificationsEnabled, isTrue);
    expect(app.state.settings.scheduleVersion, currentScheduleVersion);
    expect(gateway.scheduleCalls, greaterThan(previousScheduleCalls));
    expect(app.state.scheduling, SchedulingState.idle);
  });

  test('save failure keeps the previous UI settings', () async {
    final store = _Store();
    final app = _controller(store, _Gateway());
    await app.initialize();
    store.failWrite = true;

    await app.updateNotificationFrequency(NotificationFrequency.chatty);

    expect(
      app.state.settings.notificationFrequency,
      NotificationFrequency.normal,
    );
    expect(app.state.scheduling, SchedulingState.failed);
    expect(app.state.userVisibleError, 'settings_write_failed');
  });

  test(
    'rebuild failure keeps candidate settings and disables notifications',
    () async {
      final store = _Store();
      final gateway = _Gateway()..permission = true;
      final app = _controller(store, gateway);
      await app.initialize();
      await app.requestPermissionAndEnableNotifications();
      gateway.failSchedule = true;
      final window = NotificationWindow.tryCreate(
        startMinute: 420,
        endMinute: 1200,
      )!;

      await app.updateNotificationWindow(window);

      expect(app.state.settings.notificationWindow, same(window));
      expect(app.state.settings.notificationsEnabled, isFalse);
      expect(store.value.notificationsEnabled, isFalse);
      expect(app.state.scheduling, SchedulingState.failed);
      expect(app.state.userVisibleError, 'notification_settings_apply_failed');
    },
  );

  test('existing users receive one launch-scoped in-app message', () async {
    final store = _Store()
      ..value = AppSettings.defaults().copyWith(onboardingCompleted: true);
    final app = _controller(store, _Gateway());

    await app.initialize();

    expect(app.state.phase, AppPhase.home);
    expect(app.state.inAppMessage, isNotNull);
    expect(store.value.lastInAppMessageId, app.state.inAppMessage!.id);
    expect(app.state.settings.recentContentIds, isEmpty);
    expect(app.state.settings.recentCategories, isEmpty);
  });

  test(
    'resume and notification setting changes keep the same message',
    () async {
      final store = _Store()
        ..value = AppSettings.defaults().copyWith(onboardingCompleted: true);
      final app = _controller(store, _Gateway());
      await app.initialize();
      final selected = app.state.inAppMessage;

      await app.onAppResumed();
      await app.updateNotificationFrequency(NotificationFrequency.quiet);

      expect(app.state.inAppMessage, same(selected));
    },
  );

  test(
    'in-app id write failure does not break home or remove message',
    () async {
      final store = _Store()
        ..value = AppSettings.defaults().copyWith(onboardingCompleted: true)
        ..failWrite = true;
      final app = _controller(store, _Gateway());

      await app.initialize();

      expect(app.state.phase, AppPhase.home);
      expect(app.state.inAppMessage, isNotNull);
      expect(app.state.settings.notificationsEnabled, isFalse);
    },
  );
}
