import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import 'selection_card.dart';

class VoiceSelectionPage extends StatefulWidget {
  const VoiceSelectionPage({
    required this.language,
    required this.onContinue,
    required this.onBack,
    super.key,
  });
  final AppLanguage language;
  final ValueChanged<MotherVoice> onContinue;
  final VoidCallback onBack;

  @override
  State<VoiceSelectionPage> createState() => _VoiceSelectionPageState();
}

class _VoiceSelectionPageState extends State<VoiceSelectionPage> {
  MotherVoice? _selection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = widget.language == AppLanguage.ja
        ? <(MotherVoice, String, String)>[
            (MotherVoice.jaStandard, l10n.jaStandard, l10n.exampleJaStandard),
            (MotherVoice.jaKansai, l10n.jaKansai, l10n.exampleJaKansai),
          ]
        : <(MotherVoice, String, String)>[
            (MotherVoice.enNeutral, l10n.enNeutral, l10n.exampleEnNeutral),
            (MotherVoice.enBritish, l10n.enBritish, l10n.exampleEnBritish),
          ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(l10n.chooseVoice),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            for (final option in options)
              SelectionCard(
                value: option.$1,
                groupValue: _selection,
                title: option.$2,
                subtitle: option.$3,
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
