import 'package:flutter/material.dart';

import '../content/mother_message.dart';

class InAppMessageCard extends StatelessWidget {
  const InAppMessageCard({
    required this.message,
    required this.heading,
    super.key,
  });

  final MotherMessage message;
  final String heading;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$heading. ${message.body}',
    container: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(heading, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message.body),
          ],
        ),
      ),
    ),
  );
}
