import 'dart:convert';
import 'dart:io';

const allowedFields = <String>{'id', 'language', 'voice', 'category', 'body'};
const allowedCategories = <String>{
  'admonition',
  'daily',
  'fictional_gossip',
  'fake_tip',
  'caring',
  'contextless',
  'useful',
};
const validVoices = <String, Set<String>>{
  'ja': {'standard', 'kansai'},
  'en': {'neutral', 'british'},
};
const blockedTerms = <String>[
  '自殺',
  '殺して',
  '治療',
  '処方',
  'guaranteed cure',
  'kill yourself',
];

void main() {
  final file = File('assets/content/messages.json');
  final errors = <String>[];
  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on Object catch (error) {
    stderr.writeln('Invalid JSON: $error');
    exitCode = 1;
    return;
  }
  if (decoded is! List<Object?>) {
    stderr.writeln('Content root must be an array.');
    exitCode = 1;
    return;
  }
  final ids = <String>{};
  final bodies = <String>{};
  final counts = <String, int>{};
  final idPattern = RegExp(
    r'^(ja-(standard|kansai)|en-(neutral|british))-(admonition|daily|fictional_gossip|fake_tip|caring|contextless|useful)-[0-9]{4}$',
  );
  final controls = RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]');

  for (var index = 0; index < decoded.length; index++) {
    final item = decoded[index];
    if (item is! Map<String, Object?>) {
      errors.add('[$index] must be an object');
      continue;
    }
    final unknown = item.keys.toSet().difference(allowedFields);
    final missing = allowedFields.difference(item.keys.toSet());
    if (unknown.isNotEmpty) errors.add('[$index] unknown fields: $unknown');
    if (missing.isNotEmpty) errors.add('[$index] missing fields: $missing');
    if (unknown.isNotEmpty || missing.isNotEmpty) continue;
    final id = item['id'];
    final language = item['language'];
    final voice = item['voice'];
    final category = item['category'];
    final body = item['body'];
    if (id is! String || !idPattern.hasMatch(id)) {
      errors.add('[$index] invalid id');
    }
    if (language is! String || !validVoices.containsKey(language)) {
      errors.add('[$index] invalid language');
      continue;
    }
    if (voice is! String || !validVoices[language]!.contains(voice)) {
      errors.add('[$index] invalid language/voice combination');
      continue;
    }
    if (category is! String || !allowedCategories.contains(category)) {
      errors.add('[$index] invalid category');
      continue;
    }
    if (id is String && !id.startsWith('$language-$voice-$category-')) {
      errors.add('[$index] id does not match fields');
    }
    if (id is String && !ids.add(id)) errors.add('[$index] duplicate id: $id');
    if (body is! String || body.trim().isEmpty || body.length > 90) {
      errors.add('[$index] body must contain 1–90 characters');
    } else {
      if (!bodies.add(body)) errors.add('[$index] duplicate body');
      if (controls.hasMatch(body)) {
        errors.add('[$index] body has control characters');
      }
      final lower = body.toLowerCase();
      for (final term in blockedTerms) {
        if (lower.contains(term.toLowerCase())) {
          errors.add('[$index] blocked term: $term');
        }
      }
    }
    counts['$language-$voice'] = (counts['$language-$voice'] ?? 0) + 1;
  }
  for (final voice in const [
    'ja-standard',
    'ja-kansai',
    'en-neutral',
    'en-british',
  ]) {
    if ((counts[voice] ?? 0) < 40) {
      errors.add('$voice has fewer than 40 messages');
    }
  }
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('Validated ${decoded.length} provisional messages: $counts');
  stdout.writeln(
    'Automated validation passed. Human editorial audit is still required.',
  );
}
