import 'package:flutter/material.dart';

import '../app/app_view_state.dart';
import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.state,
    required this.onNotificationChanged,
    required this.onEditLanguageVoice,
    required this.onOpenSystemSettings,
    required this.onRetry,
    super.key,
  });

  final AppViewState state;
  final ValueChanged<bool> onNotificationChanged;
  final VoidCallback onEditLanguageVoice;
  final VoidCallback onOpenSystemSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final working = state.scheduling == SchedulingState.working;
    final failed = state.scheduling == SchedulingState.failed;
    final denied = state.permission == NotificationPermissionState.denied;
    final status = working
        ? l10n.statusWorking
        : failed
        ? l10n.statusFailed
        : denied
        ? l10n.statusPermissionDenied
        : state.settings.notificationsEnabled
        ? l10n.statusEnabled
        : l10n.statusStopped;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      label:
                          '${l10n.notificationSwitchLabel}、${state.settings.notificationsEnabled ? 'ON' : 'OFF'}',
                      toggled: state.settings.notificationsEnabled,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.notificationHeading),
                        value: state.settings.notificationsEnabled,
                        onChanged: working ? null : onNotificationChanged,
                      ),
                    ),
                    Text(status),
                    if (working) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (failed) ...[
                      const SizedBox(height: 8),
                      Text(l10n.notificationUnavailable),
                      if (state.userVisibleError != null) ...[
                        const SizedBox(height: 4),
                        Text('${l10n.errorCode}: ${state.userVisibleError}'),
                      ],
                      TextButton(onPressed: onRetry, child: Text(l10n.retry)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.settings,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ListTile(
              minVerticalPadding: 12,
              leading: const Icon(Icons.translate),
              title: Text(l10n.changeLanguageVoice),
              subtitle: Text(
                '${_languageName(l10n, state.settings.language)} · ${_voiceName(l10n, state.settings.voice)}',
              ),
              onTap: working ? null : onEditLanguageVoice,
            ),
            ListTile(
              minVerticalPadding: 12,
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.openNotificationSettings),
              onTap: onOpenSystemSettings,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutTitle),
              subtitle: Text(l10n.aboutBody),
            ),
            ListTile(
              leading: const Icon(Icons.theater_comedy_outlined),
              title: Text(l10n.jokeNoticeTitle),
              subtitle: Text(l10n.jokeNoticeBody),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(AppLocalizations l10n, AppLanguage language) =>
      language == AppLanguage.ja ? l10n.japanese : l10n.english;

  String _voiceName(AppLocalizations l10n, MotherVoice voice) =>
      switch (voice) {
        MotherVoice.jaStandard => l10n.jaStandard,
        MotherVoice.jaKansai => l10n.jaKansai,
        MotherVoice.enNeutral => l10n.enNeutral,
        MotherVoice.enBritish => l10n.enBritish,
      };
}
