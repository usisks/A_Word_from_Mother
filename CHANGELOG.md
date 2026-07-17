# Changelog

## Unreleased

### Implemented for v0.2.0 (release pending)

- Added configurable notification start and end times from 07:00 to 23:00 in 30-minute steps, with a three-hour minimum window.
- Added quiet, normal, and chatty notification frequency choices while preserving the 90-minute minimum interval.
- Added one in-app message that remains fixed during each app launch and is independent of notification history and scheduling.
- Expanded bundled content candidates to 80 messages per voice and 320 total. The 160 new candidates still require the recorded human review before Release.
- Added v0.1.0 settings migration without re-onboarding and pending-schedule reconstruction through `scheduleVersion`.

v0.2.0 is not released. Human content audit and Android physical-device gates remain mandatory.

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
