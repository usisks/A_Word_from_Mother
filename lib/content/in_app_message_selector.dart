import '../core/random_source.dart';
import '../settings/app_settings.dart';
import 'mother_message.dart';

final class InAppMessageSelector {
  factory InAppMessageSelector({
    required List<MotherMessage> messages,
    required RandomSource random,
  }) => InAppMessageSelector._(messages, random);

  InAppMessageSelector._(List<MotherMessage> messages, this._random)
    : _messages = List<MotherMessage>.unmodifiable(messages);

  final List<MotherMessage> _messages;
  final RandomSource _random;

  MotherMessage? select({
    required AppLanguage language,
    required MotherVoice voice,
    required String? previousMessageId,
  }) {
    final matching = _messages
        .where(
          (message) => message.language == language && message.voice == voice,
        )
        .toList(growable: false);
    if (matching.isEmpty) return null;

    final alternatives = matching
        .where((message) => message.id != previousMessageId)
        .toList(growable: false);
    final candidates = alternatives.isEmpty ? matching : alternatives;
    return candidates[_random.nextInt(candidates.length)];
  }
}
