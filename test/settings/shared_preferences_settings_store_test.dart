import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:a_word_from_mother/settings/notification_window.dart';
import 'package:a_word_from_mother/settings/shared_preferences_settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _MemoryPreferences implements SharedPreferencesAsync {
  _MemoryPreferences([Map<String, Object>? values])
    : _values = <String, Object>{...?values};

  final Map<String, Object> _values;

  @override
  Future<void> clear({Set<String>? allowList}) async {
    if (allowList == null) {
      _values.clear();
    } else {
      _values.removeWhere((key, _) => allowList.contains(key));
    }
  }

  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async =>
      Map<String, Object?>.fromEntries(
        _values.entries.where(
          (entry) => allowList == null || allowList.contains(entry.key),
        ),
      );

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _values[key] as double?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async => _values.keys
      .where((key) => allowList == null || allowList.contains(key))
      .toSet();

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<List<String>?> getStringList(String key) async =>
      (_values[key] as List<Object?>?)?.cast<String>().toList();

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setDouble(String key, double value) async =>
      _values[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _values[key] = List<String>.of(value);
}

void main() {
  test('reads v0.1.0 settings with v0.2.0 defaults', () async {
    final preferences = _MemoryPreferences(<String, Object>{
      'onboarding_completed': true,
      'language': 'en',
      'voice': 'en_british',
      'notifications_enabled': true,
      'recent_content_ids': <String>['id-1'],
      'recent_categories': <String>['daily'],
    });

    final settings = await SharedPreferencesSettingsStore(
      preferences: preferences,
    ).read();

    expect(settings.onboardingCompleted, isTrue);
    expect(settings.language, AppLanguage.en);
    expect(settings.voice, MotherVoice.enBritish);
    expect(settings.notificationsEnabled, isTrue);
    expect(
      settings.notificationWindow.startMinute,
      NotificationWindow.defaults.startMinute,
    );
    expect(
      settings.notificationWindow.endMinute,
      NotificationWindow.defaults.endMinute,
    );
    expect(settings.notificationFrequency, NotificationFrequency.normal);
    expect(settings.scheduleVersion, 0);
    expect(settings.lastInAppMessageId, isNull);
  });

  test('writes and reads all v0.2.0 fields', () async {
    final store = SharedPreferencesSettingsStore(
      preferences: _MemoryPreferences(),
    );
    final window = NotificationWindow.tryCreate(
      startMinute: 420,
      endMinute: 1200,
    )!;
    final expected = AppSettings.defaults().copyWith(
      onboardingCompleted: true,
      notificationWindow: window,
      notificationFrequency: NotificationFrequency.chatty,
      scheduleVersion: 2,
      lastInAppMessageId: 'en-neutral-daily-0041',
    );

    await store.write(expected);
    final actual = await store.read();

    expect(actual.onboardingCompleted, isTrue);
    expect(actual.notificationWindow.startMinute, 420);
    expect(actual.notificationWindow.endMinute, 1200);
    expect(actual.notificationFrequency, NotificationFrequency.chatty);
    expect(actual.scheduleVersion, 2);
    expect(actual.lastInAppMessageId, 'en-neutral-daily-0041');
  });

  test('normalizes an invalid window and rebuilds enabled schedules', () async {
    final preferences = _MemoryPreferences(<String, Object>{
      'notifications_enabled': true,
      'notification_start_minute': 420,
      'notification_end_minute': 540,
      'schedule_version': 2,
    });

    final settings = await SharedPreferencesSettingsStore(
      preferences: preferences,
    ).read();

    expect(settings.notificationsEnabled, isTrue);
    expect(settings.notificationWindow, same(NotificationWindow.defaults));
    expect(settings.scheduleVersion, 0);
  });

  test(
    'normalizes an unknown frequency and rebuilds enabled schedules',
    () async {
      final preferences = _MemoryPreferences(<String, Object>{
        'notifications_enabled': true,
        'notification_frequency': 'often',
        'schedule_version': 2,
      });

      final settings = await SharedPreferencesSettingsStore(
        preferences: preferences,
      ).read();

      expect(settings.notificationFrequency, NotificationFrequency.normal);
      expect(settings.scheduleVersion, 0);
    },
  );

  test('keeps an existing valid v0.2.0 schedule version', () async {
    final preferences = _MemoryPreferences(<String, Object>{
      'notifications_enabled': true,
      'notification_start_minute': 420,
      'notification_end_minute': 1200,
      'notification_frequency': 'quiet',
      'schedule_version': 2,
    });

    final settings = await SharedPreferencesSettingsStore(
      preferences: preferences,
    ).read();

    expect(settings.notificationFrequency, NotificationFrequency.quiet);
    expect(settings.scheduleVersion, 2);
  });

  test('removes a null last in-app message id', () async {
    final preferences = _MemoryPreferences(<String, Object>{
      'last_in_app_message_id': 'old-id',
    });
    final store = SharedPreferencesSettingsStore(preferences: preferences);

    await store.write(AppSettings.defaults());
    final settings = await store.read();

    expect(settings.lastInAppMessageId, isNull);
  });

  test(
    'invalid language and voice combination disables notifications',
    () async {
      final preferences = _MemoryPreferences(<String, Object>{
        'language': 'ja',
        'voice': 'en_british',
        'notifications_enabled': true,
      });

      final settings = await SharedPreferencesSettingsStore(
        preferences: preferences,
      ).read();

      expect(settings.language, AppLanguage.ja);
      expect(settings.voice, MotherVoice.jaStandard);
      expect(settings.notificationsEnabled, isFalse);
    },
  );
}
