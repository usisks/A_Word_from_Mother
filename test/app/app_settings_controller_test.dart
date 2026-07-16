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
  @override
  Future<void> clearRecentHistory() async {}
  @override
  Future<AppSettings> read() async => value;
  @override
  Future<void> write(AppSettings settings) async => value = settings;
}

class _Gateway implements NotificationGateway {
  bool permission = false;
  var cancelCalls = 0;
  @override
  Future<bool> areNotificationsEnabled() async => permission;
  @override
  Future<void> cancelAll() async {
    cancelCalls++;
  }
  @override
  Future<void> initialize() async {}
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

AppSettingsController controller(_Store store, _Gateway gateway) =>
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
  test('first launch progresses to Home without requesting permission', () async {
    final store = _Store();
    final app = controller(store, _Gateway());
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
  });

  test('permission denial finishes onboarding safely with notifications off', () async {
    final store = _Store();
    final app = controller(store, _Gateway());
    await app.initialize();
    await app.requestPermissionAndEnableNotifications();
    expect(app.state.phase, AppPhase.home);
    expect(app.state.permission, NotificationPermissionState.denied);
    expect(app.state.settings.notificationsEnabled, isFalse);
    expect(app.state.userVisibleError, 'permission_denied');
  });
}
