enum NotificationWindowValidationError {
  outOfRange,
  invalidStep,
  sameTime,
  startNotBeforeEnd,
  durationTooShort,
}

final class NotificationWindowValidation {
  const NotificationWindowValidation.valid(this.value) : error = null;

  const NotificationWindowValidation.invalid(this.error) : value = null;

  final NotificationWindow? value;
  final NotificationWindowValidationError? error;

  bool get isValid => value != null;
}

final class NotificationWindow {
  const NotificationWindow._({
    required this.startMinute,
    required this.endMinute,
  });

  static const int stepMinutes = 30;
  static const int minimumDurationMinutes = 180;
  static const int earliestAllowedMinute = 420;
  static const int latestAllowedMinute = 1380;
  static const int deliverySafetyMarginMinutes = 90;

  static const NotificationWindow defaults = NotificationWindow._(
    startMinute: 480,
    endMinute: 1320,
  );

  final int startMinute;
  final int endMinute;

  int get durationMinutes => endMinute - startMinute;

  int get latestReservationMinute => endMinute - deliverySafetyMarginMinutes;

  static NotificationWindowValidation validate({
    required int startMinute,
    required int endMinute,
  }) {
    if (startMinute < earliestAllowedMinute ||
        startMinute > latestAllowedMinute ||
        endMinute < earliestAllowedMinute ||
        endMinute > latestAllowedMinute) {
      return const NotificationWindowValidation.invalid(
        NotificationWindowValidationError.outOfRange,
      );
    }
    if (startMinute % stepMinutes != 0 || endMinute % stepMinutes != 0) {
      return const NotificationWindowValidation.invalid(
        NotificationWindowValidationError.invalidStep,
      );
    }
    if (startMinute == endMinute) {
      return const NotificationWindowValidation.invalid(
        NotificationWindowValidationError.sameTime,
      );
    }
    if (startMinute > endMinute) {
      return const NotificationWindowValidation.invalid(
        NotificationWindowValidationError.startNotBeforeEnd,
      );
    }
    if (endMinute - startMinute < minimumDurationMinutes) {
      return const NotificationWindowValidation.invalid(
        NotificationWindowValidationError.durationTooShort,
      );
    }
    return NotificationWindowValidation.valid(
      NotificationWindow._(startMinute: startMinute, endMinute: endMinute),
    );
  }

  static NotificationWindow? tryCreate({
    required int startMinute,
    required int endMinute,
  }) => validate(startMinute: startMinute, endMinute: endMinute).value;
}
