// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'A Word from Mom';

  @override
  String get tagline => 'Occasional little messages, right on your phone.';

  @override
  String get chooseLanguage => 'Choose a language';

  @override
  String get chooseVoice => 'Choose how Mom sounds';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get jaStandard => 'Standard Japanese';

  @override
  String get jaKansai => 'Kansai dialect';

  @override
  String get enNeutral => 'Neutral English';

  @override
  String get enBritish => 'British English';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get selected => 'selected';

  @override
  String get exampleJaStandard =>
      'Decide what you want before opening the fridge.';

  @override
  String get exampleJaKansai =>
      'Did you bring your umbrella? The sky looks unsure.';

  @override
  String get exampleEnNeutral =>
      'Bring a layer. Rooms have opinions about temperature.';

  @override
  String get exampleEnBritish =>
      'Take a brolly. The clouds look rather committed.';

  @override
  String get permissionTitle => 'A note about notifications';

  @override
  String get permissionTiming =>
      'Messages arrive at changing times from morning to evening.';

  @override
  String get permissionStop => 'You can stop them at any time.';

  @override
  String get permissionJokes =>
      'Some life tips are fictional jokes. Please treat them as humour.';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get notNow => 'Not now';

  @override
  String get notificationHeading => 'Messages from Mom';

  @override
  String get statusEnabled =>
      'She\'ll probably have something to say later today.';

  @override
  String get statusStopped => 'Messages from Mom are stopped.';

  @override
  String get statusPermissionDenied =>
      'Notifications are not allowed in device settings.';

  @override
  String get statusWorking => 'Preparing notifications…';

  @override
  String get statusFailed => 'Notifications could not be prepared.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get voice => 'Voice';

  @override
  String get changeLanguageVoice => 'Change language and voice';

  @override
  String get openNotificationSettings => 'Open device notification settings';

  @override
  String get aboutTitle => 'About this app';

  @override
  String get aboutBody =>
      'This offline app chooses from messages bundled with the app. It has no account, ads, analytics, or network access.';

  @override
  String get jokeNoticeTitle => 'Fictional tip notice';

  @override
  String get jokeNoticeBody =>
      'Some messages are intentionally made-up jokes, not factual, medical, legal, or safety advice.';

  @override
  String get retry => 'Try again';

  @override
  String get startupError => 'The app data could not be loaded.';

  @override
  String get notificationUnavailable =>
      'Notifications are temporarily unavailable. You can continue using the app with notifications off.';

  @override
  String get errorCode => 'Error code';

  @override
  String get notificationSwitchLabel => 'Messages from Mom';

  @override
  String get byTheWay => 'By the way';

  @override
  String get notificationTime => 'Notification time';

  @override
  String get notificationFrequency => 'Notification frequency';

  @override
  String get notificationStartTime => 'Start time';

  @override
  String get notificationEndTime => 'End time';

  @override
  String notificationWindowValue(String start, String end) {
    return '$start – $end';
  }

  @override
  String get frequencyQuiet => 'Quiet';

  @override
  String get frequencyNormal => 'Normal';

  @override
  String get frequencyChatty => 'Chatty';

  @override
  String get frequencyQuietDescription => '1–2 messages per day';

  @override
  String get frequencyNormalDescription => '2–4 messages per day';

  @override
  String get frequencyChattyDescription => '4–6 messages per day';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get notificationTimeSame => 'Choose different start and end times.';

  @override
  String get notificationTimeOrder =>
      'The start time must be before the end time.';

  @override
  String get notificationTimeTooShort =>
      'The notification window must be at least 3 hours.';

  @override
  String get notificationTimeOutOfRange =>
      'Choose a time between 7:00 and 23:00.';

  @override
  String get notificationTimeInvalidStep => 'Choose a time in 30-minute steps.';

  @override
  String get notificationTimingNote =>
      'Messages are scheduled a little earlier to reduce late delivery.';

  @override
  String get settingsSaveFailed => 'The setting could not be saved.';

  @override
  String get notificationSettingsApplyFailed =>
      'Notifications were stopped because the new schedule could not be prepared.';
}
