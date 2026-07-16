import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import 'selection_card.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({required this.onContinue, super.key});
  final ValueChanged<AppLanguage> onContinue;

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  AppLanguage? _selection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.tagline, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 28),
            Text(
              l10n.chooseLanguage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            SelectionCard(
              value: AppLanguage.ja,
              groupValue: _selection,
              title: l10n.japanese,
              onSelected: (value) => setState(() => _selection = value),
            ),
            SelectionCard(
              value: AppLanguage.en,
              groupValue: _selection,
              title: l10n.english,
              onSelected: (value) => setState(() => _selection = value),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _selection == null
                  ? null
                  : () => widget.onContinue(_selection!),
              child: Text(l10n.next),
            ),
          ],
        ),
      ),
    );
  }
}
