# Test plan

## Automated gates

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`
4. `dart run tool/validate_content.dart`
5. `flutter build apk --debug`
6. `flutter build appbundle --release`

## Physical-device result reported for v0.1.0

The following results were confirmed by the tester and recorded on 2026-07-16:

- The app launched successfully on an Android physical device.
- The first-run setup completed successfully.
- A notification was received after permission was granted.
- The notification text rendered correctly.
- The notification actions operated as expected.
- All 160 bundled messages completed a human editorial and safety review in addition to automated validation.

The device model, Android version, and original execution date were not recorded, so no model-specific or OS-specific claim is made.

## Additional device coverage still required

Test fresh install, allow/deny notification permission, OS setting changes, app terminated and locked, both dismiss-only actions, body tap, notification off/cancellation, reboot and update restoration, battery saver, time-zone changes, day rollover, channel disabled, and release icon rendering. Cover API 24, 32, 33, 34, 35, and 36 where practical, including the Xiaomi 14T Pro called out by the product specification.

Because inexact alarms can be delayed by Android or an OEM, future testing should record actual delivery times for the 20:30 slot and whether any notification appears after 22:00. The confirmed physical-device result does not cover every OEM battery policy, Android version, reboot condition, or time-zone scenario, and the app does not guarantee a hard night-time cutoff.

## v0.2.0 planned automated coverage

The following coverage is planned for v0.2.0 and is not evidence of implemented behavior in v0.1.0.

- `NotificationWindow` boundary tests: 07:00 and 23:00 bounds, 30-minute increments, equal/reversed times, and the three-hour minimum duration.
- `NotificationFrequency` range tests: quiet (1–2), normal (2–4), and chatty (4–6) requested counts.
- Scheduler tests that preserve a minimum 90-minute interval and never reserve after the end time minus 90 minutes.
- Scheduler tests that reduce the number of notifications, rather than shorten the interval, when a short window has insufficient capacity.
- `scheduleVersion` mismatch tests that rebuild the pending schedule.
- v0.1.0 settings migration tests that preserve onboarding, language, voice, notification state, history, and existing metadata without re-onboarding.
- In-app message selection tests, including exact language/voice matching and independence from notification history and schedule selection.
- Widget rebuild tests that verify the selected in-app message does not change during the same app launch.
- Japanese and English widget tests for the added notification settings and in-app message presentation.

## v0.2.0 planned Android device coverage

- Install v0.1.0, set up the app, then install v0.2.0 over it and confirm settings migration, schedule reconstruction, and no re-onboarding.
- On Xiaomi 14T Pro, verify notification permission transitions, time-window boundaries, quiet/normal/chatty behavior, update restoration, reboot, battery saver, notification actions, and delayed late-night delivery behavior.
