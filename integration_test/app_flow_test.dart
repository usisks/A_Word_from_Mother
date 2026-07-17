import 'package:a_word_from_mother/app/app_settings_controller.dart';
import 'package:a_word_from_mother/app/mother_word_app.dart';
import 'package:a_word_from_mother/content/in_app_message_selector.dart';
import 'package:a_word_from_mother/core/clock.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/notifications/notification_gateway.dart';
import 'package:a_word_from_mother/notifications/notification_scheduler.dart';
import 'package:a_word_from_mother/platform/time_zone_service.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
  @override
  Future<bool> areNotificationsEnabled() async => false;
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> openSystemNotificationSettings() async {}
  @override
  Future<int> pendingCount() async => 0;
  @override
  Future<bool> requestPermission() async => false;
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding can continue without requesting permission', (
    tester,
  ) async {
    final gateway = _Gateway();
    final controller = AppSettingsController(
      store: _Store(),
      gateway: gateway,
      scheduler: NotificationScheduler(
        gateway: gateway,
        messages: const [],
        timeZoneService: TimeZoneService(),
        clock: _Clock(),
        random: _Random(),
      ),
      inAppMessageSelector: InAppMessageSelector(
        messages: const [],
        random: _Random(),
      ),
    );
    await controller.initialize();
    await tester.pumpWidget(MotherWordApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('日本語').last);
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('標準語'));
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('今は許可しない'));
    await tester.pumpAndSettle();

    expect(find.text('母からの通知'), findsWidgets);
    expect(find.byType(Switch), findsOneWidget);
  });
}
