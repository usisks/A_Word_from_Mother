import '../settings/app_settings.dart';

enum MessageCategory {
  admonition,
  daily,
  fictionalGossip,
  fakeTip,
  caring,
  contextless,
  useful;

  String get value => switch (this) {
    fictionalGossip => 'fictional_gossip',
    fakeTip => 'fake_tip',
    _ => name,
  };

  static MessageCategory parse(String value) => values.firstWhere(
    (category) => category.value == value,
    orElse: () => throw FormatException('Unknown category: $value'),
  );
}

class MotherMessage {
  const MotherMessage({
    required this.id,
    required this.language,
    required this.voice,
    required this.category,
    required this.body,
  });

  factory MotherMessage.fromJson(Map<String, Object?> json) {
    const fields = <String>{'id', 'language', 'voice', 'category', 'body'};
    if (json.keys.toSet().difference(fields).isNotEmpty ||
        fields.difference(json.keys.toSet()).isNotEmpty) {
      throw const FormatException('Invalid message fields');
    }
    final language = switch (json['language']) {
      'ja' => AppLanguage.ja,
      'en' => AppLanguage.en,
      _ => throw const FormatException('Invalid language'),
    };
    final voice = MotherVoiceValue.tryParse(
      '${json['language']}_${json['voice']}',
    );
    final body = json['body'];
    final id = json['id'];
    final category = json['category'];
    if (voice == null ||
        voice.language != language ||
        body is! String ||
        body.isEmpty ||
        body.length > 90 ||
        id is! String ||
        category is! String) {
      throw const FormatException('Invalid message value');
    }
    return MotherMessage(
      id: id,
      language: language,
      voice: voice,
      category: MessageCategory.parse(category),
      body: body,
    );
  }

  final String id;
  final AppLanguage language;
  final MotherVoice voice;
  final MessageCategory category;
  final String body;
}
