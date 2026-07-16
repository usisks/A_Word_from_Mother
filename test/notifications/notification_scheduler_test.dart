import 'package:a_word_from_mother/core/clock.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/notifications/notification_gateway.dart';
import 'package:a_word_from_mother/notifications/notification_scheduler.dart';
import 'package:a_word_from_mother/platform/time_zone_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock implements Clock {
  _Clock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _SequenceRandom implements RandomSource {
  _SequenceRandom(this.values);
  final List<int> values;
  var index = 0;
  @override
  int nextInt(int max) => values[index++ % values.length] % max;
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

NotificationScheduler scheduler(DateTime now, List<int> random) =>
    NotificationScheduler(
      gateway: _Gateway(),
      messages: const [],
      timeZoneService: TimeZoneService(),
      clock: _Clock(now),
      random: _SequenceRandom(random),
    );

void main() {
  test('full days contain 2-4 times between 08:00 and 20:30', () {
    final service = scheduler(DateTime(2026, 7, 16, 7), [2, 0, 100, 200, 300]);
    final times = service.generateTimesForDay(
      date: DateTime(2026, 7, 17),
      now: DateTime(2026, 7, 16, 7),
      isToday: false,
    );
    expect(times.length, inInclusiveRange(2, 4));
    expect(times.first.hour * 60 + times.first.minute, greaterThanOrEqualTo(480));
    expect(times.last.hour * 60 + times.last.minute, lessThanOrEqualTo(1230));
    for (var index = 1; index < times.length; index++) {
      expect(times[index].difference(times[index - 1]).inMinutes, greaterThanOrEqualTo(90));
    }
  });

  test('today never schedules before now plus 30 minutes', () {
    final now = DateTime(2026, 7, 16, 12, 10);
    final times = scheduler(now, [0, 0, 0]).generateTimesForDay(
      date: DateTime(2026, 7, 16),
      now: now,
      isToday: true,
    );
    expect(times.first.isBefore(now.add(const Duration(minutes: 30))), isFalse);
  });

  test('today after 20:30 has no reservation', () {
    final now = DateTime(2026, 7, 16, 20, 1);
    final times = scheduler(now, [0]).generateTimesForDay(
      date: DateTime(2026, 7, 16),
      now: now,
      isToday: true,
    );
    expect(times, isEmpty);
  });

  test('notification IDs are stable and slot-unique', () {
    final date = DateTime(2026, 7, 16);
    expect(NotificationScheduler.notificationId(date, 0), 202607160);
    expect(NotificationScheduler.notificationId(date, 1), 202607161);
  });
}
