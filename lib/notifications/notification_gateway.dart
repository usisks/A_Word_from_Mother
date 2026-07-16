class ScheduledMotherNotification {
  const ScheduledMotherNotification({
    required this.id,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payload,
    required this.huhLabel,
    required this.okayLabel,
    required this.channelName,
    required this.channelDescription,
  });

  final int id;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String payload;
  final String huhLabel;
  final String okayLabel;
  final String channelName;
  final String channelDescription;
}

abstract interface class NotificationGateway {
  Future<void> initialize();
  Future<bool> areNotificationsEnabled();
  Future<bool> requestPermission();
  Future<void> schedule(ScheduledMotherNotification notification);
  Future<void> cancelAll();
  Future<int> pendingCount();
  Future<void> openSystemNotificationSettings();
}
