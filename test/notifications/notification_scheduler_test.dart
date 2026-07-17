import 'package:a_word_from_mother/core/clock.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/notifications/notification_gateway.dart';
import 'package:a_word_from_mother/notifications/notification_scheduler.dart';
import 'package:a_word_from_mother/platform/time_zone_service.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:a_word_from_mother/settings/notification_window.dart';
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
  int pending = 0;
  int cancelCalls = 0;
  final List<ScheduledMotherNotification> scheduled = [];

  @override
  Future<bool> areNotificationsEnabled() async => false;
  @override
  Future<void> cancelAll() async => cancelCalls++;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> openSystemNotificationSettings() async {}
  @override
  Future<int> pendingCount() async => pending;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule(ScheduledMotherNotification notification) async =>
      scheduled.add(notification);
}

class _TimeZoneService extends TimeZoneService {
  @override
  Future<String> initialize() async => 'Asia/Tokyo';
}

NotificationScheduler _scheduler(
  DateTime now,
  List<int> random, {
  _Gateway? gateway,
}) => NotificationScheduler(
  gateway: gateway ?? _Gateway(),
  messages: const [],
  timeZoneService: _TimeZoneService(),
  clock: _Clock(now),
  random: _SequenceRandom(random),
);

void _expectValidTimes(
  List<DateTime> times, {
  required NotificationWindow window,
}) {
  expect(
    times.first.hour * 60 + times.first.minute,
    greaterThanOrEqualTo(window.startMinute),
  );
  expect(
    times.last.hour * 60 + times.last.minute,
    lessThanOrEqualTo(window.latestReservationMinute),
  );
  for (var index = 1; index < times.length; index++) {
    expect(
      times[index].difference(times[index - 1]).inMinutes,
      greaterThanOrEqualTo(90),
    );
  }
}

void main() {
  test('default full days contain 2-4 times from 08:00 to 20:30', () {
    final service = _scheduler(DateTime(2026, 7, 16, 7), [2, 0, 100, 200, 300]);
    final times = service.generateTimesForDay(
      date: DateTime(2026, 7, 17),
      now: DateTime(2026, 7, 16, 7),
      isToday: false,
      window: NotificationWindow.defaults,
      frequency: NotificationFrequency.normal,
    );

    expect(times.length, inInclusiveRange(2, 4));
    _expectValidTimes(times, window: NotificationWindow.defaults);
  });

  for (final frequency in NotificationFrequency.values) {
    test('${frequency.name} uses its configured daily range', () {
      final service = _scheduler(DateTime(2026, 7, 16, 7), [99, 0, 0, 0, 0, 0]);
      final times = service.generateTimesForDay(
        date: DateTime(2026, 7, 17),
        now: DateTime(2026, 7, 16, 7),
        isToday: false,
        window: NotificationWindow.defaults,
        frequency: frequency,
      );

      expect(
        times.length,
        inInclusiveRange(
          frequency.minimumDailyCount,
          frequency.maximumDailyCount,
        ),
      );
      _expectValidTimes(times, window: NotificationWindow.defaults);
    });
  }

  test('short windows reduce chatty count without reducing the gap', () {
    final window = NotificationWindow.tryCreate(
      startMinute: 600,
      endMinute: 780,
    )!;
    final times = _scheduler(DateTime(2026, 7, 16, 7), [2, 0, 0, 0, 0, 0])
        .generateTimesForDay(
          date: DateTime(2026, 7, 17),
          now: DateTime(2026, 7, 16, 7),
          isToday: false,
          window: window,
          frequency: NotificationFrequency.chatty,
        );

    expect(times.length, 2);
    _expectValidTimes(times, window: window);
  });

  test('today never schedules before now plus 30 minutes', () {
    final now = DateTime(2026, 7, 16, 12, 10);
    final times = _scheduler(now, [0, 0, 0]).generateTimesForDay(
      date: DateTime(2026, 7, 16),
      now: now,
      isToday: true,
      window: NotificationWindow.defaults,
      frequency: NotificationFrequency.normal,
    );
    expect(times.first.isBefore(now.add(const Duration(minutes: 30))), isFalse);
  });

  test('today after the last possible time has no reservation', () {
    final now = DateTime(2026, 7, 16, 20, 1);
    final times = _scheduler(now, [0]).generateTimesForDay(
      date: DateTime(2026, 7, 16),
      now: now,
      isToday: true,
      window: NotificationWindow.defaults,
      frequency: NotificationFrequency.normal,
    );
    expect(times, isEmpty);
  });

  test('today returns empty when now plus 30 minutes is another day', () {
    final now = DateTime(2026, 12, 31, 23, 45);
    final times = _scheduler(now, [0]).generateTimesForDay(
      date: DateTime(2026, 12, 31),
      now: now,
      isToday: true,
      window: NotificationWindow.defaults,
      frequency: NotificationFrequency.normal,
    );
    expect(times, isEmpty);
  });

  test('schedule version mismatch causes a rebuild', () async {
    final gateway = _Gateway()..pending = 100;
    final service = _scheduler(DateTime(2026, 7, 16, 7), [0], gateway: gateway);
    final settings = AppSettings.defaults().copyWith(
      lastScheduleRefreshAt: DateTime(2026, 7, 15),
      lastTimeZoneId: 'Asia/Tokyo',
      scheduleVersion: 0,
    );

    final summary = await service.ensureSchedule(settings: settings);

    expect(gateway.cancelCalls, 1);
    expect(summary.scheduleVersion, currentScheduleVersion);
  });

  test('frequency controls the minimum pending threshold', () async {
    final gateway = _Gateway()..pending = 27;
    final service = _scheduler(DateTime(2026, 7, 16, 7), [0], gateway: gateway);
    final settings = AppSettings.defaults().copyWith(
      notificationFrequency: NotificationFrequency.chatty,
      lastScheduleRefreshAt: DateTime(2026, 7, 15),
      lastTimeZoneId: 'Asia/Tokyo',
      scheduleVersion: currentScheduleVersion,
    );

    await service.ensureSchedule(settings: settings);

    expect(gateway.cancelCalls, 1);
  });

  test(
    'notification IDs are stable and slot-unique across date boundaries',
    () {
      expect(
        NotificationScheduler.notificationId(DateTime(2026, 7, 16), 0),
        202607160,
      );
      expect(
        NotificationScheduler.notificationId(DateTime(2026, 7, 16), 1),
        202607161,
      );
      expect(
        NotificationScheduler.notificationId(DateTime(2026, 12, 31), 5),
        202612315,
      );
      expect(
        NotificationScheduler.notificationId(DateTime(2027, 1, 1), 0),
        202701010,
      );
    },
  );
}
