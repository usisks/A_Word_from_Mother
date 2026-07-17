# Changelog

## 0.2.0 - 2026-07-17

### Added

- Added configurable notification start and end times from 07:00 to 23:00 in 30-minute steps, with a three-hour minimum window.
- Added quiet, normal, and chatty notification frequency choices while preserving the 90-minute minimum interval.
- Added one in-app message that remains fixed during each app launch and is independent of notification history and scheduling.
- Expanded reviewed bundled content to 80 messages per voice and 320 total.

### Changed

- Migrated v0.1.0 settings without repeating onboarding.
- Rebuilt pending notification schedules through `scheduleVersion` 2.

### Verified

- Completed human editorial, safety, language or dialect, and similarity review for all 160 new messages.
- Confirmed the update path and required behavior on an Android physical device with no critical or major defect reported.
- Verified dedicated Android Release signing for the APK and AAB.
- Did not run the automated Android integration test because no supported target was connected. Product owner やまと waived that check for the v0.2.0 Release after accepting the manual Android result.

## 0.1.0 - 2026-07-16

- Created the Android-only Flutter MVP foundation.
- Added Japanese and English onboarding with four voice choices.
- Added local settings, defensive recovery, and notification enable/disable handling.
- Added bundled content, validation, repeat avoidance, and category rotation.
- Added 30-day inexact local scheduling, notification actions, reboot receivers, and time-zone refresh.
- Added unit, widget, and integration test foundations and implementation documentation.
- Fixed release startup by retaining the notification icon and making notification initialization failures non-fatal.
- Confirmed app launch, onboarding, notification receipt, notification text rendering, and notification actions on an Android physical device.
- Completed a human editorial and safety review of all 160 bundled messages.
- Required dedicated Android release signing for release APK and AAB builds.

The device model and OS version were not recorded. OEM battery behavior, all Android versions, and all reboot conditions have not been exhaustively tested.
