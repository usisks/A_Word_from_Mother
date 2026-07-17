import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:a_word_from_mother/settings/notification_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults include v0.2.0 settings', () {
    final settings = AppSettings.defaults();

    expect(settings.notificationWindow, same(NotificationWindow.defaults));
    expect(settings.notificationFrequency, NotificationFrequency.normal);
    expect(settings.scheduleVersion, 0);
    expect(settings.lastInAppMessageId, isNull);
  });

  test('copyWith trims message and category history', () {
    final settings = AppSettings.defaults().copyWith(
      recentContentIds: List.generate(35, (index) => 'id-$index'),
      recentCategories: const ['one', 'two', 'three'],
    );
    expect(settings.recentContentIds.length, 30);
    expect(settings.recentContentIds.first, 'id-5');
    expect(settings.recentCategories, ['two', 'three']);
  });

  test('each voice exposes its valid language', () {
    expect(MotherVoice.jaStandard.language, AppLanguage.ja);
    expect(MotherVoice.jaKansai.language, AppLanguage.ja);
    expect(MotherVoice.enNeutral.language, AppLanguage.en);
    expect(MotherVoice.enBritish.language, AppLanguage.en);
  });

  test('copyWith updates and clears v0.2.0 settings', () {
    final window = NotificationWindow.tryCreate(
      startMinute: 420,
      endMinute: 1200,
    )!;
    final original = AppSettings.defaults().copyWith(
      lastInAppMessageId: 'message-1',
    );

    final updated = original.copyWith(
      notificationWindow: window,
      notificationFrequency: NotificationFrequency.chatty,
      scheduleVersion: 2,
      clearLastInAppMessageId: true,
    );

    expect(updated.notificationWindow, same(window));
    expect(updated.notificationFrequency, NotificationFrequency.chatty);
    expect(updated.scheduleVersion, 2);
    expect(updated.lastInAppMessageId, isNull);
  });
}
