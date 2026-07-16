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
flutter build appbundle --release
```

## Design notes and limitations

- `docs/PRODUCT_SPEC.md` is the source of truth.
- The implementation decisions are `com.usisks.mothersword` for the application ID and `A Word from Mom` for the English product name.
- Notifications are scheduled locally for 30 days using inexact alarms between 08:00 and 20:30. Android/OEM delay can still cause a later delivery; a strict 22:00 cutoff is not guaranteed.
- The schedule is repaired on app launch/resume when stale, sparse, or after a detected time-zone change. If the time zone changes and the app is never reopened, old reservations may retain the former zone.
- Some OEM battery policies may suppress notifications. Physical-device testing is required.
- The 160 bundled messages are provisional and pass structural validation only. Human editorial review is required before publication.
- Release currently uses the debug signing configuration solely so a local release AAB can be compiled. Store signing and release publication are intentionally outside this MVP implementation.
