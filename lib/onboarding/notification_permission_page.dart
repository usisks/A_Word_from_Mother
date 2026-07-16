import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({
    required this.working,
    required this.onAllow,
    required this.onSkip,
    super.key,
  });
  final bool working;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _Fact(icon: Icons.schedule, text: l10n.permissionTiming),
            _Fact(
              icon: Icons.notifications_off_outlined,
              text: l10n.permissionStop,
            ),
            _Fact(
              icon: Icons.sentiment_satisfied_alt,
              text: l10n.permissionJokes,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: working ? null : onAllow,
              child: Text(l10n.allowNotifications),
            ),
            TextButton(
              onPressed: working ? null : onSkip,
              child: Text(l10n.notNow),
            ),
            if (working) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
