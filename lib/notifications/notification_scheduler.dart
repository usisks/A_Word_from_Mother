import 'dart:convert';
import 'dart:math' as math;

import '../content/content_selector.dart';
import '../content/mother_message.dart';
import '../core/clock.dart';
import '../core/random_source.dart';
import '../platform/time_zone_service.dart';
import '../settings/app_settings.dart';
import '../settings/notification_frequency.dart';
import '../settings/notification_window.dart';
import 'notification_constants.dart';
import 'notification_gateway.dart';

const int currentScheduleVersion = 2;

class ScheduleSummary {
  const ScheduleSummary({
    required this.scheduledCount,
    required this.recentContentIds,
    required this.recentCategories,
    required this.timeZoneId,
    required this.scheduleVersion,
  });
  final int scheduledCount;
  final List<String> recentContentIds;
  final List<String> recentCategories;
  final String timeZoneId;
  final int scheduleVersion;
}

class NotificationScheduler {
  NotificationScheduler({
    required NotificationGateway gateway,
    required List<MotherMessage> messages,
    required TimeZoneService timeZoneService,
    required Clock clock,
    required RandomSource random,
    ContentSelector selector = const ContentSelector(),
  }) : this._(gateway, messages, timeZoneService, clock, random, selector);

  NotificationScheduler._(
    this._gateway,
    this._messages,
    this._timeZoneService,
    this._clock,
    this._random,
    this._selector,
  );

  final NotificationGateway _gateway;
  final List<MotherMessage> _messages;
  final TimeZoneService _timeZoneService;
  final Clock _clock;
  final RandomSource _random;
  final ContentSelector _selector;

  Future<ScheduleSummary> rebuild({required AppSettings settings}) async {
    await _gateway.cancelAll();
    final timeZoneId = await _timeZoneService.initialize();
    final now = _clock.now();
    final recentIds = settings.recentContentIds.toList();
    final recentCategories = settings.recentCategories.toList();
    var scheduledCount = 0;

    for (var dayOffset = 0; dayOffset < 30; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      final times = generateTimesForDay(
        date: date,
        now: now,
        isToday: dayOffset == 0,
        window: settings.notificationWindow,
        frequency: settings.notificationFrequency,
      );
      for (var slot = 0; slot < times.length; slot++) {
        final message = _selector.select(
          messages: _messages,
          language: settings.language,
          voice: settings.voice,
          recentIds: recentIds,
          recentCategories: recentCategories,
          random: _random,
        );
        if (message == null) continue;
        final title = switch (settings.voice) {
          MotherVoice.jaStandard || MotherVoice.jaKansai => '母',
          MotherVoice.enNeutral => 'Mom',
          MotherVoice.enBritish => 'Mum',
        };
        final isJapanese = settings.language == AppLanguage.ja;
        await _gateway.schedule(
          ScheduledMotherNotification(
            id: notificationId(date, slot),
            scheduledAt: times[slot],
            title: title,
            body: message.body,
            payload: jsonEncode(<String, Object>{
              'v': 1,
              'type': notificationPayloadType,
              'contentId': message.id,
            }),
            huhLabel: isJapanese ? 'へー' : 'Huh',
            okayLabel: isJapanese ? 'おっけ' : 'Okay',
            channelName: isJapanese ? '母からの一言' : 'Messages from Mom',
            channelDescription: isJapanese
                ? '母から届いたような一言を表示します'
                : 'Shows occasional messages from Mom',
          ),
        );
        recentIds.add(message.id);
        if (recentIds.length > 30) recentIds.removeAt(0);
        recentCategories.add(message.category.value);
        if (recentCategories.length > 2) recentCategories.removeAt(0);
        scheduledCount++;
      }
    }
    return ScheduleSummary(
      scheduledCount: scheduledCount,
      recentContentIds: List.unmodifiable(recentIds),
      recentCategories: List.unmodifiable(recentCategories),
      timeZoneId: timeZoneId,
      scheduleVersion: currentScheduleVersion,
    );
  }

  Future<ScheduleSummary> ensureSchedule({
    required AppSettings settings,
  }) async {
    final timeZoneId = await _timeZoneService.initialize();
    final now = _clock.now();
    final refreshedAt = settings.lastScheduleRefreshAt;
    final pendingCount = await _gateway.pendingCount();
    final stale =
        refreshedAt == null ||
        now.difference(refreshedAt).inDays >= 23 ||
        settings.lastTimeZoneId != timeZoneId ||
        settings.scheduleVersion != currentScheduleVersion ||
        pendingCount < minimumPendingCount(settings);
    if (stale) return rebuild(settings: settings);
    return ScheduleSummary(
      scheduledCount: pendingCount,
      recentContentIds: settings.recentContentIds,
      recentCategories: settings.recentCategories,
      timeZoneId: timeZoneId,
      scheduleVersion: currentScheduleVersion,
    );
  }

  Future<void> cancelAll() => _gateway.cancelAll();

  List<DateTime> generateTimesForDay({
    required DateTime date,
    required DateTime now,
    required bool isToday,
    required NotificationWindow window,
    required NotificationFrequency frequency,
  }) {
    final endMinute = window.latestReservationMinute;
    var startMinute = window.startMinute;
    if (isToday) {
      final earliest = now.add(const Duration(minutes: 30));
      if (earliest.year != date.year ||
          earliest.month != date.month ||
          earliest.day != date.day) {
        return const [];
      }
      startMinute = math.max(startMinute, earliest.hour * 60 + earliest.minute);
      if (startMinute > endMinute) return const [];
    }
    final capacity = ((endMinute - startMinute) ~/ 90) + 1;
    if (capacity <= 0) return const [];
    final count = math.min(selectTargetDailyCount(frequency), capacity);
    final slack = endMinute - startMinute - (90 * (count - 1));
    final offsets = List<int>.generate(
      count,
      (_) => slack == 0 ? 0 : _random.nextInt(slack + 1),
    )..sort();
    return List<DateTime>.generate(count, (index) {
      final minute = startMinute + offsets[index] + (90 * index);
      return DateTime(
        date.year,
        date.month,
        date.day,
        minute ~/ 60,
        minute % 60,
      );
    });
  }

  int selectTargetDailyCount(NotificationFrequency frequency) {
    final width = frequency.maximumDailyCount - frequency.minimumDailyCount + 1;
    return frequency.minimumDailyCount + _random.nextInt(width);
  }

  int minimumPendingCount(AppSettings settings) =>
      settings.notificationFrequency.minimumDailyCount * 7;

  static int notificationId(DateTime date, int slotIndex) =>
      (date.year * 10000 + date.month * 100 + date.day) * 10 + slotIndex;
}
