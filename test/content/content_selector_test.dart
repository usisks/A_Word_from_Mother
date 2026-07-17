import 'package:a_word_from_mother/content/content_selector.dart';
import 'package:a_word_from_mother/content/content_loader.dart';
import 'package:a_word_from_mother/content/mother_message.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

class _ZeroRandom implements RandomSource {
  @override
  int nextInt(int max) => 0;
}

MotherMessage message(
  String id,
  AppLanguage language,
  MotherVoice voice,
  MessageCategory category,
) => MotherMessage(
  id: id,
  language: language,
  voice: voice,
  category: category,
  body: id,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const selector = ContentSelector();
  final random = _ZeroRandom();

  test('bundled content loads with 80 messages per voice', () async {
    final messages = await const ContentLoader().load();
    expect(messages, hasLength(320));
    for (final voice in MotherVoice.values) {
      expect(
        messages.where((message) => message.voice == voice),
        hasLength(80),
      );
    }
  });

  test('excludes recent IDs and a category used twice', () {
    final messages = [
      message(
        'recent',
        AppLanguage.ja,
        MotherVoice.jaKansai,
        MessageCategory.daily,
      ),
      message(
        'blocked',
        AppLanguage.ja,
        MotherVoice.jaKansai,
        MessageCategory.caring,
      ),
      message(
        'chosen',
        AppLanguage.ja,
        MotherVoice.jaKansai,
        MessageCategory.useful,
      ),
    ];
    final selected = selector.select(
      messages: messages,
      language: AppLanguage.ja,
      voice: MotherVoice.jaKansai,
      recentIds: const ['recent'],
      recentCategories: const ['caring', 'caring'],
      random: random,
    );
    expect(selected?.id, 'chosen');
  });

  test('falls back only to standard voice in the same language', () {
    final selected = selector.select(
      messages: [
        message(
          'standard',
          AppLanguage.ja,
          MotherVoice.jaStandard,
          MessageCategory.daily,
        ),
        message(
          'english',
          AppLanguage.en,
          MotherVoice.enNeutral,
          MessageCategory.daily,
        ),
      ],
      language: AppLanguage.ja,
      voice: MotherVoice.jaKansai,
      recentIds: const [],
      recentCategories: const [],
      random: random,
    );
    expect(selected?.id, 'standard');
  });

  test('returns null when no same-language candidate remains', () {
    final selected = selector.select(
      messages: [
        message(
          'english',
          AppLanguage.en,
          MotherVoice.enNeutral,
          MessageCategory.daily,
        ),
      ],
      language: AppLanguage.ja,
      voice: MotherVoice.jaKansai,
      recentIds: const [],
      recentCategories: const [],
      random: random,
    );
    expect(selected, isNull);
  });

  test('rejects a mismatched language and voice', () {
    expect(
      () => selector.select(
        messages: const [],
        language: AppLanguage.en,
        voice: MotherVoice.jaStandard,
        recentIds: const [],
        recentCategories: const [],
        random: random,
      ),
      throwsArgumentError,
    );
  });
}
