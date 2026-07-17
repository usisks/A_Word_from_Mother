import 'package:a_word_from_mother/app/app_view_state.dart';
import 'package:a_word_from_mother/content/mother_message.dart';
import 'package:a_word_from_mother/home/home_page.dart';
import 'package:a_word_from_mother/home/in_app_message_card.dart';
import 'package:a_word_from_mother/l10n/app_localizations.dart';
import 'package:a_word_from_mother/settings/app_settings.dart';
import 'package:a_word_from_mother/settings/notification_frequency.dart';
import 'package:a_word_from_mother/settings/notification_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _message = MotherMessage(
  id: 'en-neutral-daily-0001',
  language: AppLanguage.en,
  voice: MotherVoice.enNeutral,
  category: MessageCategory.daily,
  body: 'Take a layer.',
);

AppViewState _state({
  MotherMessage? message = _message,
  SchedulingState scheduling = SchedulingState.idle,
  AppLanguage language = AppLanguage.en,
}) => AppViewState(
  phase: AppPhase.home,
  settings: AppSettings.defaults().copyWith(
    onboardingCompleted: true,
    language: language,
    voice: language.defaultVoice,
  ),
  permission: NotificationPermissionState.granted,
  scheduling: scheduling,
  inAppMessage: message,
);

Future<void> _pumpHome(
  WidgetTester tester, {
  required AppViewState state,
  Future<void> Function(NotificationWindow)? onWindowChanged,
  Future<void> Function(NotificationFrequency)? onFrequencyChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(state.settings.language.name),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(
        state: state,
        onNotificationChanged: (_) {},
        onNotificationWindowChanged: onWindowChanged ?? (_) async {},
        onNotificationFrequencyChanged: onFrequencyChanged ?? (_) async {},
        onEditLanguageVoice: () {},
        onOpenSystemSettings: () {},
        onRetry: () {},
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('notification card stays above the in-app message card', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state());

    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.byType(InAppMessageCard), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SwitchListTile)).dy,
      lessThan(tester.getTopLeft(find.byType(InAppMessageCard)).dy),
    );
  });

  testWidgets('in-app message card has no action buttons', (tester) async {
    await _pumpHome(tester, state: _state());

    expect(find.text('By the way'), findsOneWidget);
    expect(find.text('Take a layer.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(InAppMessageCard),
        matching: find.byType(ButtonStyleButton),
      ),
      findsNothing,
    );
  });

  testWidgets('in-app message card is hidden when selection is null', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state(message: null));

    expect(find.byType(InAppMessageCard), findsNothing);
  });

  testWidgets('notification window sheet shows localized controls', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state());

    await tester.tap(find.text('Notification time'));
    await tester.pumpAndSettle();

    expect(find.text('Start time'), findsOneWidget);
    expect(find.text('End time'), findsOneWidget);
    expect(
      find.text(
        'Messages are scheduled a little earlier to reduce late delivery.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('frequency sheet offers all three localized choices', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state());

    await tester.tap(find.text('Notification frequency'));
    await tester.pumpAndSettle();

    expect(find.text('Quiet'), findsOneWidget);
    expect(find.text('Normal'), findsWidgets);
    expect(find.text('Chatty'), findsOneWidget);
    expect(find.text('1–2 messages per day'), findsOneWidget);
    expect(find.text('4–6 messages per day'), findsOneWidget);
  });

  testWidgets('working state disables scheduling settings', (tester) async {
    var windowCalls = 0;
    var frequencyCalls = 0;
    await _pumpHome(
      tester,
      state: _state(scheduling: SchedulingState.working),
      onWindowChanged: (_) async => windowCalls++,
      onFrequencyChanged: (_) async => frequencyCalls++,
    );

    await tester.tap(find.text('Notification time'));
    await tester.tap(find.text('Notification frequency'));
    await tester.pump();

    expect(find.text('Start time'), findsNothing);
    expect(find.text('Quiet'), findsNothing);
    expect(windowCalls, 0);
    expect(frequencyCalls, 0);
  });

  testWidgets('renders Japanese v0.2.0 labels', (tester) async {
    await _pumpHome(tester, state: _state(language: AppLanguage.ja));

    expect(find.text('ところで'), findsOneWidget);
    expect(find.text('通知時間'), findsOneWidget);
    expect(find.text('通知頻度'), findsOneWidget);
    expect(find.text('普通'), findsOneWidget);
  });

  testWidgets('widget rebuild keeps the displayed message', (tester) async {
    final state = _state();
    await _pumpHome(tester, state: state);
    await _pumpHome(tester, state: state);

    expect(find.text('Take a layer.'), findsOneWidget);
  });
}
