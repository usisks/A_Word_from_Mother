import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines storage values and daily count ranges', () {
    expect(NotificationFrequency.quiet.storageValue, 'quiet');
    expect(NotificationFrequency.quiet.minimumDailyCount, 1);
    expect(NotificationFrequency.quiet.maximumDailyCount, 2);
    expect(NotificationFrequency.normal.storageValue, 'normal');
    expect(NotificationFrequency.normal.minimumDailyCount, 2);
    expect(NotificationFrequency.normal.maximumDailyCount, 4);
    expect(NotificationFrequency.chatty.storageValue, 'chatty');
    expect(NotificationFrequency.chatty.minimumDailyCount, 4);
    expect(NotificationFrequency.chatty.maximumDailyCount, 6);
  });

  test('parses known storage values', () {
    expect(
      NotificationFrequency.parseOrDefault('quiet'),
      NotificationFrequency.quiet,
    );
    expect(
      NotificationFrequency.parseOrDefault('normal'),
      NotificationFrequency.normal,
    );
    expect(
      NotificationFrequency.parseOrDefault('chatty'),
      NotificationFrequency.chatty,
    );
  });

  test('defaults null and unknown storage values to normal', () {
    expect(
      NotificationFrequency.parseOrDefault(null),
      NotificationFrequency.normal,
    );
    expect(
      NotificationFrequency.parseOrDefault('unknown'),
      NotificationFrequency.normal,
    );
  });
}
