import 'dart:convert';

import 'package:flutter/services.dart';

import 'mother_message.dart';

class ContentLoader {
  const ContentLoader({AssetBundle? bundle}) : this._(bundle);

  const ContentLoader._(this._bundle);

  final AssetBundle? _bundle;

  Future<List<MotherMessage>> load() async {
    final source = await (_bundle ?? rootBundle).loadString(
      'assets/content/messages.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! List<Object?>) {
      throw const FormatException('Content root must be an array');
    }
    final messages = decoded
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Message must be an object');
          }
          return MotherMessage.fromJson(item);
        })
        .toList(growable: false);
    if (messages.isEmpty ||
        messages.map((m) => m.id).toSet().length != messages.length) {
      throw const FormatException('Content is empty or contains duplicate IDs');
    }
    return messages;
  }
}
