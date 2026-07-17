import 'notification_frequency.dart';
import 'notification_window.dart';

enum AppLanguage { ja, en }

enum MotherVoice { jaStandard, jaKansai, enNeutral, enBritish }

extension AppLanguageValue on AppLanguage {
  String get value => name;
  MotherVoice get defaultVoice =>
      this == AppLanguage.ja ? MotherVoice.jaStandard : MotherVoice.enNeutral;
}

extension MotherVoiceValue on MotherVoice {
  AppLanguage get language => switch (this) {
    MotherVoice.jaStandard || MotherVoice.jaKansai => AppLanguage.ja,
    MotherVoice.enNeutral || MotherVoice.enBritish => AppLanguage.en,
  };

  String get value => switch (this) {
    MotherVoice.jaStandard => 'ja_standard',
    MotherVoice.jaKansai => 'ja_kansai',
    MotherVoice.enNeutral => 'en_neutral',
    MotherVoice.enBritish => 'en_british',
  };

  String get contentValue => value.split('_').last;

  static MotherVoice? tryParse(String? value) => switch (value) {
    'ja_standard' => MotherVoice.jaStandard,
    'ja_kansai' => MotherVoice.jaKansai,
    'en_neutral' => MotherVoice.enNeutral,
    'en_british' => MotherVoice.enBritish,
    _ => null,
  };
}

class AppSettings {
  const AppSettings({
    required this.onboardingCompleted,
    required this.language,
    required this.voice,
    required this.notificationsEnabled,
    required this.recentContentIds,
    required this.recentCategories,
    required this.notificationWindow,
    required this.notificationFrequency,
    required this.scheduleVersion,
    this.lastScheduleRefreshAt,
    this.lastTimeZoneId,
    this.lastInAppMessageId,
  });

  factory AppSettings.defaults() => const AppSettings(
    onboardingCompleted: false,
    language: AppLanguage.ja,
    voice: MotherVoice.jaStandard,
    notificationsEnabled: false,
    recentContentIds: <String>[],
    recentCategories: <String>[],
    notificationWindow: NotificationWindow.defaults,
    notificationFrequency: NotificationFrequency.normal,
    scheduleVersion: 0,
  );

  final bool onboardingCompleted;
  final AppLanguage language;
  final MotherVoice voice;
  final bool notificationsEnabled;
  final List<String> recentContentIds;
  final List<String> recentCategories;
  final NotificationWindow notificationWindow;
  final NotificationFrequency notificationFrequency;
  final DateTime? lastScheduleRefreshAt;
  final String? lastTimeZoneId;
  final int scheduleVersion;
  final String? lastInAppMessageId;

  AppSettings copyWith({
    bool? onboardingCompleted,
    AppLanguage? language,
    MotherVoice? voice,
    bool? notificationsEnabled,
    List<String>? recentContentIds,
    List<String>? recentCategories,
    NotificationWindow? notificationWindow,
    NotificationFrequency? notificationFrequency,
    DateTime? lastScheduleRefreshAt,
    String? lastTimeZoneId,
    int? scheduleVersion,
    String? lastInAppMessageId,
    bool clearLastScheduleRefreshAt = false,
    bool clearLastInAppMessageId = false,
  }) => AppSettings(
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    language: language ?? this.language,
    voice: voice ?? this.voice,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    recentContentIds: List.unmodifiable(
      (recentContentIds ?? this.recentContentIds).takeLast(30),
    ),
    recentCategories: List.unmodifiable(
      (recentCategories ?? this.recentCategories).takeLast(2),
    ),
    notificationWindow: notificationWindow ?? this.notificationWindow,
    notificationFrequency: notificationFrequency ?? this.notificationFrequency,
    lastScheduleRefreshAt: clearLastScheduleRefreshAt
        ? null
        : (lastScheduleRefreshAt ?? this.lastScheduleRefreshAt),
    lastTimeZoneId: lastTimeZoneId ?? this.lastTimeZoneId,
    scheduleVersion: scheduleVersion ?? this.scheduleVersion,
    lastInAppMessageId: clearLastInAppMessageId
        ? null
        : (lastInAppMessageId ?? this.lastInAppMessageId),
  );
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final values = toList(growable: false);
    return values.skip(values.length > count ? values.length - count : 0);
  }
}
