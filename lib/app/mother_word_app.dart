import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../home/home_page.dart';
import '../l10n/app_localizations.dart';
import '../onboarding/language_selection_page.dart';
import '../onboarding/notification_permission_page.dart';
import '../onboarding/voice_selection_page.dart';
import 'app_settings_controller.dart';
import 'app_view_state.dart';

class MotherWordApp extends StatefulWidget {
  const MotherWordApp({required this.controller, super.key});
  final AppSettingsController controller;

  @override
  State<MotherWordApp> createState() => _MotherWordAppState();
}

class _MotherWordAppState extends State<MotherWordApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: Locale(state.settings.language.name),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9A4E63),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.standard,
        ),
        home: _pageFor(state),
      );
    },
  );

  Widget _pageFor(AppViewState state) => switch (state.phase) {
    AppPhase.loading => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    AppPhase.languageSelection => LanguageSelectionPage(
      onContinue: widget.controller.completeLanguageSelection,
      notificationWarningCode: _notificationWarning(state.userVisibleError),
      onRetryNotificationSetup: widget.controller.retryNotificationSetup,
      retrying: state.scheduling == SchedulingState.working,
    ),
    AppPhase.voiceSelection => VoiceSelectionPage(
      language: state.settings.language,
      onContinue: widget.controller.completeVoiceSelection,
      onBack: widget.controller.backToLanguageSelection,
    ),
    AppPhase.permissionExplanation => NotificationPermissionPage(
      working: state.scheduling == SchedulingState.working,
      onAllow: widget.controller.requestPermissionAndEnableNotifications,
      onSkip: widget.controller.completeOnboardingWithoutNotifications,
    ),
    AppPhase.home => HomePage(
      state: state,
      onNotificationChanged: widget.controller.setNotificationsEnabled,
      onEditLanguageVoice: widget.controller.editLanguageAndVoice,
      onOpenSystemSettings: widget.controller.openSystemNotificationSettings,
      onRetry: widget.controller.retryScheduling,
    ),
    AppPhase.startupError => _StartupErrorPage(
      errorCode: state.userVisibleError ?? 'startup_failed',
      onRetry: widget.controller.initialize,
    ),
  };

  String? _notificationWarning(String? errorCode) => switch (errorCode) {
    'notification_initialize_failed' ||
    'notification_permission_check_failed' ||
    'notification_permission_request_failed' => errorCode,
    _ => null,
  };
}

class _StartupErrorPage extends StatelessWidget {
  const _StartupErrorPage({required this.errorCode, required this.onRetry});

  final String errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).startupError),
              const SizedBox(height: 12),
              Text('${AppLocalizations.of(context).errorCode}: $errorCode'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
