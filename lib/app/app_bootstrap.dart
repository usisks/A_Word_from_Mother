import '../content/content_loader.dart';
import '../content/in_app_message_selector.dart';
import '../content/mother_message.dart';
import '../core/clock.dart';
import '../core/diagnostics.dart';
import '../core/random_source.dart';
import '../notifications/flutter_notification_gateway.dart';
import '../notifications/notification_scheduler.dart';
import '../platform/time_zone_service.dart';
import '../settings/shared_preferences_settings_store.dart';
import 'app_settings_controller.dart';

Future<AppSettingsController> bootstrapApp() async {
  final messages = await _loadContent();
  final gateway = FlutterNotificationGateway();
  final schedulerRandom = DartRandomSource();
  final inAppMessageRandom = DartRandomSource();
  final controller = AppSettingsController(
    store: _createSettingsStore(),
    gateway: gateway,
    scheduler: NotificationScheduler(
      gateway: gateway,
      messages: messages,
      timeZoneService: TimeZoneService(),
      clock: const SystemClock(),
      random: schedulerRandom,
    ),
    inAppMessageSelector: InAppMessageSelector(
      messages: messages,
      random: inAppMessageRandom,
    ),
  );
  gateway.onNotificationBodyTap = controller.showHomeFromNotification;
  await controller.initialize();
  return controller;
}

SharedPreferencesSettingsStore _createSettingsStore() {
  try {
    return SharedPreferencesSettingsStore();
  } on Object catch (error, stackTrace) {
    logFailure('settings_read_failed', error, stackTrace);
    throw const AppBootstrapException('settings_read_failed');
  }
}

Future<List<MotherMessage>> _loadContent() async {
  try {
    return await const ContentLoader().load();
  } on Object catch (error, stackTrace) {
    logFailure('content_load_failed', error, stackTrace);
    throw const AppBootstrapException('content_load_failed');
  }
}

class AppBootstrapException implements Exception {
  const AppBootstrapException(this.code);

  final String code;

  @override
  String toString() => code;
}
