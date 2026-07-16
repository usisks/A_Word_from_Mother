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
