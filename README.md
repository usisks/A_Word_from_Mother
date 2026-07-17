# 母の一言 / A Word from Mom

An Android-only, local-first Flutter joke app that sends occasional mom-like notifications in Japanese and English. It has no server, account, advertising, analytics, or network permission.

## Requirements

- Flutter 3.44.x stable / Dart 3.12.x
- Java 17
- Android SDK 36
- Android API 24 or newer

The intended Flutter version is recorded in `.fvmrc`. Install SDKs outside the repository using your normal Flutter/FVM and Android Studio setup; do not commit `android/local.properties`.

## Run

```sh
flutter pub get
flutter gen-l10n
flutter run
```

## Verify

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
dart run tool/validate_content.dart
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Release builds require a dedicated Android signing key configured through the
git-ignored `android/key.properties`. They never fall back to the debug signing
configuration.

## v0.2.0 design status

v0.2.0 is in the design-documentation stage and is not implemented or released. The v0.1.0 behavior described below remains the current behavior. Planned requirements and implementation boundaries are recorded in the [product specification](docs/PRODUCT_SPEC.md) and [v0.2.0 detailed design](docs/V0.2.0_DETAILED_DESIGN.md).

## Design notes and limitations

- `docs/PRODUCT_SPEC.md` is the source of truth.
- The implementation decisions are `com.usisks.mothersword` for the application ID and `A Word from Mom` for the English product name.
- Notifications are scheduled locally for 30 days using inexact alarms between 08:00 and 20:30. Android/OEM delay can still cause a later delivery; a strict 22:00 cutoff is not guaranteed.
- The schedule is repaired on app launch/resume when stale, sparse, or after a detected time-zone change. If the time zone changes and the app is never reopened, old reservations may retain the former zone.
- App launch, onboarding, notification receipt, notification text rendering, and notification actions have been confirmed on an Android physical device. The device model and OS version were not recorded, so this does not claim coverage of a specific model or Android version.
- Some OEM battery policies may suppress or delay notifications. The physical-device result does not cover every manufacturer, Android version, reboot condition, or battery policy.
- The 160 bundled messages passed automated validation and a human editorial and safety review before the v0.1.0 release.
- Release artifacts use a dedicated Android release signing key. The key and its credentials are stored outside Git and must be backed up securely.
