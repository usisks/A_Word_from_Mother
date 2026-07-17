enum NotificationFrequency {
  quiet(storageValue: 'quiet', minimumDailyCount: 1, maximumDailyCount: 2),
  normal(storageValue: 'normal', minimumDailyCount: 2, maximumDailyCount: 4),
  chatty(storageValue: 'chatty', minimumDailyCount: 4, maximumDailyCount: 6);

  const NotificationFrequency({
    required this.storageValue,
    required this.minimumDailyCount,
    required this.maximumDailyCount,
  });

  final String storageValue;
  final int minimumDailyCount;
  final int maximumDailyCount;

  static NotificationFrequency parseOrDefault(String? value) => switch (value) {
    'quiet' => NotificationFrequency.quiet,
    'chatty' => NotificationFrequency.chatty,
    _ => NotificationFrequency.normal,
  };
}
