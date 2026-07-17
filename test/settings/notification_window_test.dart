import 'package:a_word_from_mother/settings/notification_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationWindow', () {
    test('accepts the default window and calculates derived values', () {
      final result = NotificationWindow.validate(
        startMinute: 480,
        endMinute: 1320,
      );

      expect(result.isValid, isTrue);
      expect(result.value!.durationMinutes, 840);
      expect(result.value!.latestReservationMinute, 1230);
    });

    test('accepts both allowed boundaries with a valid duration', () {
      final result = NotificationWindow.validate(
        startMinute: 420,
        endMinute: 1380,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts exactly three hours', () {
      final result = NotificationWindow.validate(
        startMinute: 420,
        endMinute: 600,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects values outside the allowed range first', () {
      expect(
        NotificationWindow.validate(startMinute: 390, endMinute: 600).error,
        NotificationWindowValidationError.outOfRange,
      );
      expect(
        NotificationWindow.validate(startMinute: 1200, endMinute: 1410).error,
        NotificationWindowValidationError.outOfRange,
      );
    });

    test('rejects values that are not on a thirty-minute step', () {
      expect(
        NotificationWindow.validate(startMinute: 421, endMinute: 600).error,
        NotificationWindowValidationError.invalidStep,
      );
      expect(
        NotificationWindow.validate(startMinute: 420, endMinute: 601).error,
        NotificationWindowValidationError.invalidStep,
      );
    });

    test('rejects equal start and end', () {
      expect(
        NotificationWindow.validate(startMinute: 600, endMinute: 600).error,
        NotificationWindowValidationError.sameTime,
      );
    });

    test('rejects a start after the end', () {
      expect(
        NotificationWindow.validate(startMinute: 630, endMinute: 600).error,
        NotificationWindowValidationError.startNotBeforeEnd,
      );
    });

    test('rejects a duration shorter than three hours', () {
      expect(
        NotificationWindow.validate(startMinute: 420, endMinute: 570).error,
        NotificationWindowValidationError.durationTooShort,
      );
    });

    test('tryCreate returns null for invalid values', () {
      expect(
        NotificationWindow.tryCreate(startMinute: 420, endMinute: 570),
        isNull,
      );
    });
  });
}
