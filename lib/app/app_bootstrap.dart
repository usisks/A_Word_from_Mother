import '../content/content_loader.dart';
import '../core/clock.dart';
import '../core/random_source.dart';
import '../notifications/flutter_notification_gateway.dart';
import '../notifications/notification_scheduler.dart';
import '../platform/time_zone_service.dart';
import '../settings/shared_preferences_settings_store.dart';
import 'app_settings_controller.dart';

Future<AppSettingsController> bootstrapApp() async {
  final messages = await const ContentLoader().load();
  final gateway = FlutterNotificationGateway();
  final controller = AppSettingsController(
    store: SharedPreferencesSettingsStore(),
    gateway: gateway,
    scheduler: NotificationScheduler(
      gateway: gateway,
      messages: messages,
      timeZoneService: TimeZoneService(),
      clock: const SystemClock(),
      random: DartRandomSource(),
    ),
  );
  gateway.onNotificationBodyTap = controller.showHomeFromNotification;
  await controller.initialize();
  return controller;
}
