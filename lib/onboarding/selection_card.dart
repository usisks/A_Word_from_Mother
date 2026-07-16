import 'package:flutter/material.dart';

class SelectionCard<T> extends StatelessWidget {
  const SelectionCard({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onSelected,
    this.subtitle,
    super.key,
  });

  final T value;
  final T? groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final selectedWord = Localizations.localeOf(context).languageCode == 'ja'
        ? '選択済み'
        : 'selected';
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$title、$selectedWord' : title,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
        child: InkWell(
          onTap: () => onSelected(value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(subtitle!),
                        ],
                      ],
                    ),
                  ),
                  if (selected) const Icon(Icons.check_circle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
