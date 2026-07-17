import 'package:a_word_from_mother/content/in_app_message_selector.dart';
import 'package:a_word_from_mother/content/mother_message.dart';
import 'package:a_word_from_mother/core/random_source.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

class _Random implements RandomSource {
  _Random(this.value);
  final int value;
  @override
  int nextInt(int max) => value % max;
}

const messages = <MotherMessage>[
  MotherMessage(
    id: 'ja-standard-daily-0001',
    language: AppLanguage.ja,
    voice: MotherVoice.jaStandard,
    category: MessageCategory.daily,
    body: 'one',
  ),
  MotherMessage(
    id: 'ja-standard-caring-0002',
    language: AppLanguage.ja,
    voice: MotherVoice.jaStandard,
    category: MessageCategory.caring,
    body: 'two',
  ),
  MotherMessage(
    id: 'ja-kansai-daily-0001',
    language: AppLanguage.ja,
    voice: MotherVoice.jaKansai,
    category: MessageCategory.daily,
    body: 'three',
  ),
];

void main() {
  test('selects only an exact language and voice match', () {
    final selector = InAppMessageSelector(
      messages: messages,
      random: _Random(0),
    );

    final selected = selector.select(
      language: AppLanguage.ja,
      voice: MotherVoice.jaKansai,
      previousMessageId: null,
    );

    expect(selected!.id, 'ja-kansai-daily-0001');
  });

  test('avoids the previous message when an alternative exists', () {
    final selector = InAppMessageSelector(
      messages: messages,
      random: _Random(0),
    );

    final selected = selector.select(
      language: AppLanguage.ja,
      voice: MotherVoice.jaStandard,
      previousMessageId: 'ja-standard-daily-0001',
    );

    expect(selected!.id, 'ja-standard-caring-0002');
  });

  test('allows the previous message when it is the only candidate', () {
    final selector = InAppMessageSelector(
      messages: messages,
      random: _Random(0),
    );

    final selected = selector.select(
      language: AppLanguage.ja,
      voice: MotherVoice.jaKansai,
      previousMessageId: 'ja-kansai-daily-0001',
    );

    expect(selected!.id, 'ja-kansai-daily-0001');
  });

  test('does not fall back to the default voice', () {
    final selector = InAppMessageSelector(
      messages: messages,
      random: _Random(0),
    );

    final selected = selector.select(
      language: AppLanguage.en,
      voice: MotherVoice.enBritish,
      previousMessageId: null,
    );

    expect(selected, isNull);
  });

  test('does not mutate the input list', () {
    final input = messages.toList();
    final selector = InAppMessageSelector(messages: input, random: _Random(1));

    selector.select(
      language: AppLanguage.ja,
      voice: MotherVoice.jaStandard,
      previousMessageId: null,
    );

    expect(input, messages);
  });
}
