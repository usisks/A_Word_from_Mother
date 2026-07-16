import 'package:a_word_from_mother/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fatal startup page shows its code and offers retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      FatalStartupApp(
        errorCode: 'content_load_failed',
        onRetry: () => retries++,
      ),
    );

    expect(find.text('The app data could not be loaded.'), findsOneWidget);
    expect(find.text('Error code: content_load_failed'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));

    expect(retries, 1);
  });
}
