import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
