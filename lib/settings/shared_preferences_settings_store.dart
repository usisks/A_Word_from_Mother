import 'package:shared_preferences/shared_preferences.dart';

import '../core/diagnostics.dart';
import 'app_settings.dart';
import 'notification_frequency.dart';
import 'notification_window.dart';
import 'settings_store.dart';

class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppSettings> read() async {
    try {
      final rawLanguage = await _preferences.getString('language');
      final language = switch (rawLanguage) {
        'en' => AppLanguage.en,
        _ => AppLanguage.ja,
      };
      final rawVoice = await _preferences.getString('voice');
      final storedVoice = MotherVoiceValue.tryParse(rawVoice);
      final voice = storedVoice?.language == language
          ? storedVoice!
          : language.defaultVoice;
      final settingsAreValid =
          (rawLanguage == null || rawLanguage == 'ja' || rawLanguage == 'en') &&
          (rawVoice == null || storedVoice?.language == language);
      final enabled = settingsAreValid
          ? await _preferences.getBool('notifications_enabled')
          : false;
      return AppSettings(
        onboardingCompleted:
            await _preferences.getBool('onboarding_completed') ?? false,
        language: language,
        voice: voice,
        notificationsEnabled: enabled ?? false,
        recentContentIds:
            (await _preferences.getStringList('recent_content_ids') ?? const [])
                .takeLast(30)
                .toList(growable: false),
        recentCategories:
            (await _preferences.getStringList('recent_categories') ?? const [])
                .takeLast(2)
                .toList(growable: false),
        notificationWindow: NotificationWindow.defaults,
        notificationFrequency: NotificationFrequency.normal,
        scheduleVersion: 0,
        lastScheduleRefreshAt: DateTime.tryParse(
          await _preferences.getString('last_schedule_refresh_at') ?? '',
        ),
        lastTimeZoneId: await _preferences.getString('last_time_zone_id'),
      );
    } on Object catch (error, stackTrace) {
      logFailure('settings_read_failed', error, stackTrace);
      return AppSettings.defaults();
    }
  }

  @override
  Future<void> write(AppSettings settings) async {
    await Future.wait(<Future<void>>[
      _preferences.setBool(
        'onboarding_completed',
        settings.onboardingCompleted,
      ),
      _preferences.setString('language', settings.language.value),
      _preferences.setString('voice', settings.voice.value),
      _preferences.setBool(
        'notifications_enabled',
        settings.notificationsEnabled,
      ),
      _preferences.setStringList(
        'recent_content_ids',
        settings.recentContentIds.takeLast(30).toList(growable: false),
      ),
      _preferences.setStringList(
        'recent_categories',
        settings.recentCategories.takeLast(2).toList(growable: false),
      ),
      if (settings.lastScheduleRefreshAt != null)
        _preferences.setString(
          'last_schedule_refresh_at',
          settings.lastScheduleRefreshAt!.toIso8601String(),
        )
      else
        _preferences.remove('last_schedule_refresh_at'),
      if (settings.lastTimeZoneId != null)
        _preferences.setString('last_time_zone_id', settings.lastTimeZoneId!)
      else
        _preferences.remove('last_time_zone_id'),
    ]);
  }

  @override
  Future<void> clearRecentHistory() => Future.wait(<Future<void>>[
    _preferences.remove('recent_content_ids'),
    _preferences.remove('recent_categories'),
  ]).then((_) {});
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final values = toList(growable: false);
    return values.skip(values.length > count ? values.length - count : 0);
  }
}
