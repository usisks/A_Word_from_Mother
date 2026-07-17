import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/notification_frequency.dart';

class NotificationFrequencySheet extends StatefulWidget {
  const NotificationFrequencySheet({required this.initialValue, super.key});

  final NotificationFrequency initialValue;

  @override
  State<NotificationFrequencySheet> createState() =>
      _NotificationFrequencySheetState();
}

class _NotificationFrequencySheetState
    extends State<NotificationFrequencySheet> {
  late NotificationFrequency _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.notificationFrequency,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<NotificationFrequency>(
              groupValue: _selected,
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
              child: Column(
                children: [
                  for (final frequency in NotificationFrequency.values)
                    RadioListTile<NotificationFrequency>(
                      value: frequency,
                      title: Text(_name(l10n, frequency)),
                      subtitle: Text(_description(l10n, frequency)),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _name(AppLocalizations l10n, NotificationFrequency frequency) =>
      switch (frequency) {
        NotificationFrequency.quiet => l10n.frequencyQuiet,
        NotificationFrequency.normal => l10n.frequencyNormal,
        NotificationFrequency.chatty => l10n.frequencyChatty,
      };

  String _description(AppLocalizations l10n, NotificationFrequency frequency) =>
      switch (frequency) {
        NotificationFrequency.quiet => l10n.frequencyQuietDescription,
        NotificationFrequency.normal => l10n.frequencyNormalDescription,
        NotificationFrequency.chatty => l10n.frequencyChattyDescription,
      };
}
