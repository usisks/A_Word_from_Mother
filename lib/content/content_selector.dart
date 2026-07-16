import '../core/random_source.dart';
import '../settings/app_settings.dart';
import 'mother_message.dart';

class ContentSelector {
  const ContentSelector();

  MotherMessage? select({
    required List<MotherMessage> messages,
    required AppLanguage language,
    required MotherVoice voice,
    required List<String> recentIds,
    required List<String> recentCategories,
    required RandomSource random,
  }) {
    if (voice.language != language) {
      throw ArgumentError('Voice does not belong to language');
    }
    MotherMessage? choose(MotherVoice candidateVoice) {
      final blockedCategory = recentCategories.length >= 2 &&
              recentCategories[recentCategories.length - 1] ==
                  recentCategories[recentCategories.length - 2]
          ? recentCategories.last
          : null;
      final candidates = messages
          .where(
            (message) =>
                message.language == language &&
                message.voice == candidateVoice &&
                !recentIds.contains(message.id) &&
                message.category.value != blockedCategory,
          )
          .toList(growable: false);
      return candidates.isEmpty ? null : candidates[random.nextInt(candidates.length)];
    }

    return choose(voice) ?? choose(language.defaultVoice);
  }
}
