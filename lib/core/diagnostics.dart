import 'package:flutter/foundation.dart';

void logFailure(String code, Object error, StackTrace stackTrace) {
  debugPrint(code);
  if (kDebugMode) {
    debugPrint('$code: $error\n$stackTrace');
  }
}
