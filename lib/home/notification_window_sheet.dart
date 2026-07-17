import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/notification_window.dart';

class NotificationWindowSheet extends StatefulWidget {
  const NotificationWindowSheet({required this.initialValue, super.key});

  final NotificationWindow initialValue;

  @override
  State<NotificationWindowSheet> createState() =>
      _NotificationWindowSheetState();
}

class _NotificationWindowSheetState extends State<NotificationWindowSheet> {
  late int _startMinute;
  late int _endMinute;

  NotificationWindowValidation get _validation => NotificationWindow.validate(
    startMinute: _startMinute,
    endMinute: _endMinute,
  );

  @override
  void initState() {
    super.initState();
    _startMinute = widget.initialValue.startMinute;
    _endMinute = widget.initialValue.endMinute;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validation = _validation;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.notificationTime,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _startMinute,
              decoration: InputDecoration(
                labelText: l10n.notificationStartTime,
              ),
              items: _timeItems(context),
              onChanged: (value) {
                if (value != null) setState(() => _startMinute = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _endMinute,
              decoration: InputDecoration(labelText: l10n.notificationEndTime),
              items: _timeItems(context),
              onChanged: (value) {
                if (value != null) setState(() => _endMinute = value);
              },
            ),
            const SizedBox(height: 12),
            Text(l10n.notificationTimingNote),
            if (!validation.isValid) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage(l10n, validation.error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: validation.isValid
                      ? () => Navigator.pop(context, validation.value)
                      : null,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _timeItems(BuildContext context) => [
    for (
      var minute = NotificationWindow.earliestAllowedMinute;
      minute <= NotificationWindow.latestAllowedMinute;
      minute += NotificationWindow.stepMinutes
    )
      DropdownMenuItem(
        value: minute,
        child: Text(_formatTime(context, minute)),
      ),
  ];

  String _formatTime(BuildContext context, int minute) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  String _errorMessage(
    AppLocalizations l10n,
    NotificationWindowValidationError error,
  ) => switch (error) {
    NotificationWindowValidationError.outOfRange =>
      l10n.notificationTimeOutOfRange,
    NotificationWindowValidationError.invalidStep =>
      l10n.notificationTimeInvalidStep,
    NotificationWindowValidationError.sameTime => l10n.notificationTimeSame,
    NotificationWindowValidationError.startNotBeforeEnd =>
      l10n.notificationTimeOrder,
    NotificationWindowValidationError.durationTooShort =>
      l10n.notificationTimeTooShort,
  };
}
