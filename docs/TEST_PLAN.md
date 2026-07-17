# Test plan

## Automated gates

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter gen-l10n`
3. `flutter analyze`
4. `flutter test`
5. `flutter test integration_test`
6. `dart run tool/validate_content.dart`
7. `flutter build apk --debug`
8. `flutter build apk --release`
9. `flutter build appbundle --release`

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

## v0.2.0 implemented automated coverage

The following coverage is implemented on the v0.2.0 development branch. It does not change the behavior of the public v0.1.0 Release. A passing unit/widget suite does not replace the integration or physical-device gates.

- `NotificationWindow` boundary tests: 07:00 and 23:00 bounds, 30-minute increments, equal/reversed times, and the three-hour minimum duration.
- `NotificationFrequency` range tests: quiet (1–2), normal (2–4), and chatty (4–6) requested counts.
- Scheduler tests that preserve a minimum 90-minute interval and never reserve after the end time minus 90 minutes.
- Scheduler tests that reduce the number of notifications, rather than shorten the interval, when a short window has insufficient capacity.
- `scheduleVersion` mismatch tests that rebuild the pending schedule.
- v0.1.0 settings migration tests that preserve onboarding, language, voice, notification state, history, and existing metadata without re-onboarding.
- In-app message selection tests, including exact language/voice matching and independence from notification history and schedule selection.
- Widget rebuild tests that verify the selected in-app message does not change during the same app launch.
- Japanese and English widget tests for the added notification settings and in-app message presentation.
- Bundled-content loading tests requiring 320 total messages and 80 for each voice.
- Content validation for structure, ID/body uniqueness, known categories, field consistency, length, control characters, and blocked terms.

The integration scenario covers the existing onboarding flow, in-app message display, and notification-window/frequency sheets. It must be run on a connected supported Android target; lack of a device is recorded as not run, never as passed.

## v0.2.0 automated gate result — 2026-07-17

The gate was run for version `0.2.0+3` on the development branch.

| Check | Result |
| --- | --- |
| Dependency resolution and localization generation | Passed |
| Dart formatting | Passed; 49 files checked, 0 changed |
| Flutter analysis | Passed; no issues found |
| Unit and Widget tests | Passed; 71 tests |
| Android integration test | **Not passed**; no supported Android device was connected |
| Content validation | Passed; 320 total and 80 per voice; human audit still required |
| Debug APK | Passed |
| Release APK | Passed with the configured Release certificate |
| Release AAB | Passed and JAR signature verification completed |

The Release APK reports application ID `com.usisks.mothersword`, version name `0.2.0`, version code `3`, and minimum SDK 24. Its certificate differs from the Android debug certificate, so the Release build did not fall back to debug signing. The automated gate remains incomplete until the Android integration test passes.

## v0.2.0 required Android device coverage

- Install v0.1.0, set up the app, then install v0.2.0 over it and confirm settings migration, schedule reconstruction, and no re-onboarding.
- On Xiaomi 14T Pro, verify notification permission transitions, time-window boundaries, quiet/normal/chatty behavior, update restoration, reboot, battery saver, notification actions, and delayed late-night delivery behavior.
- Record every required scenario, commit, APK checksum, device model, Android version, date, and reviewer in [`V0.2.0_DEVICE_TEST.md`](V0.2.0_DEVICE_TEST.md).
