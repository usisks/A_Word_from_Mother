import 'dart:convert';

import 'package:a_word_from_mother/content/content_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _ContentBundle extends AssetBundle {
  _ContentBundle(this.source);

  final String? source;

  @override
  Future<ByteData> load(String key) async {
    final value = source;
    if (value == null) throw FlutterError('Missing asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  test('missing content asset fails loading', () async {
    final loader = ContentLoader(bundle: _ContentBundle(null));

    await expectLater(loader.load(), throwsA(isA<FlutterError>()));
  });

  test('invalid JSON fails loading', () async {
    final loader = ContentLoader(bundle: _ContentBundle('{not json'));

    await expectLater(loader.load(), throwsA(isA<FormatException>()));
  });

  test('empty content and duplicate IDs fail validation', () async {
    await expectLater(
      ContentLoader(bundle: _ContentBundle('[]')).load(),
      throwsA(isA<FormatException>()),
    );
    const duplicate = '''
[
  {"id":"same","language":"en","voice":"neutral","category":"caring","body":"One"},
  {"id":"same","language":"en","voice":"neutral","category":"caring","body":"Two"}
]
''';
    await expectLater(
      ContentLoader(bundle: _ContentBundle(duplicate)).load(),
      throwsA(isA<FormatException>()),
    );
  });
}
