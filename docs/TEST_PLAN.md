# Test plan

## Automated gates

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`
4. `dart run tool/validate_content.dart`
5. `flutter build apk --debug`
6. `flutter build appbundle --release`

## Device coverage still required

Test fresh install, allow/deny notification permission, OS setting changes, app terminated and locked, both dismiss-only actions, body tap, notification off/cancellation, reboot and update restoration, battery saver, time-zone changes, day rollover, channel disabled, and release icon rendering. Cover API 24, 32, 33, 34, 35, and 36 where practical, including the Xiaomi 14T Pro called out by the product specification.

Because inexact alarms can be delayed by Android or an OEM, record actual delivery times for the 20:30 slot and whether any notification appears after 22:00. This MVP reduces risk but does not guarantee a hard night-time cutoff.
