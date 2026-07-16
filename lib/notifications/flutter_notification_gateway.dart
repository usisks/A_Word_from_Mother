import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../platform/android_settings_service.dart';
import 'notification_callbacks.dart';
import 'notification_constants.dart';
import 'notification_gateway.dart';

class FlutterNotificationGateway implements NotificationGateway {
  FlutterNotificationGateway({
    FlutterLocalNotificationsPlugin? plugin,
    AndroidSettingsService? settingsService,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _settingsService = settingsService ?? const AndroidSettingsService();

  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidSettingsService _settingsService;

  VoidCallback? onNotificationBodyTap;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == null || response.actionId!.isEmpty) {
          onNotificationBodyTap?.call();
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  @override
  Future<bool> areNotificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> schedule(ScheduledMotherNotification notification) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        notification.channelName,
        channelDescription: notification.channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        channelShowBadge: false,
        channelAction: AndroidNotificationChannelAction.update,
        icon: 'ic_notification',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            notificationActionHuh,
            notification.huhLabel,
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            notificationActionOkay,
            notification.okayLabel,
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    );
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(notification.scheduledAt, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notification.payload,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  @override
  Future<void> openSystemNotificationSettings() =>
      _settingsService.openNotificationSettings();
}
