import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'A Word from Mom'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Occasional little messages, right on your phone.'**
  String get tagline;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get chooseLanguage;

  /// No description provided for @chooseVoice.
  ///
  /// In en, this message translates to:
  /// **'Choose how Mom sounds'**
  String get chooseVoice;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @jaStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Japanese'**
  String get jaStandard;

  /// No description provided for @jaKansai.
  ///
  /// In en, this message translates to:
  /// **'Kansai dialect'**
  String get jaKansai;

  /// No description provided for @enNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral English'**
  String get enNeutral;

  /// No description provided for @enBritish.
  ///
  /// In en, this message translates to:
  /// **'British English'**
  String get enBritish;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @exampleJaStandard.
  ///
  /// In en, this message translates to:
  /// **'Decide what you want before opening the fridge.'**
  String get exampleJaStandard;

  /// No description provided for @exampleJaKansai.
  ///
  /// In en, this message translates to:
  /// **'Did you bring your umbrella? The sky looks unsure.'**
  String get exampleJaKansai;

  /// No description provided for @exampleEnNeutral.
  ///
  /// In en, this message translates to:
  /// **'Bring a layer. Rooms have opinions about temperature.'**
  String get exampleEnNeutral;

  /// No description provided for @exampleEnBritish.
  ///
  /// In en, this message translates to:
  /// **'Take a brolly. The clouds look rather committed.'**
  String get exampleEnBritish;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'A note about notifications'**
  String get permissionTitle;

  /// No description provided for @permissionTiming.
  ///
  /// In en, this message translates to:
  /// **'Messages arrive at changing times from morning to evening.'**
  String get permissionTiming;

  /// No description provided for @permissionStop.
  ///
  /// In en, this message translates to:
  /// **'You can stop them at any time.'**
  String get permissionStop;

  /// No description provided for @permissionJokes.
  ///
  /// In en, this message translates to:
  /// **'Some life tips are fictional jokes. Please treat them as humour.'**
  String get permissionJokes;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @notificationHeading.
  ///
  /// In en, this message translates to:
  /// **'Messages from Mom'**
  String get notificationHeading;

  /// No description provided for @statusEnabled.
  ///
  /// In en, this message translates to:
  /// **'She\'ll probably have something to say later today.'**
  String get statusEnabled;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Messages from Mom are stopped.'**
  String get statusStopped;

  /// No description provided for @statusPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed in device settings.'**
  String get statusPermissionDenied;

  /// No description provided for @statusWorking.
  ///
  /// In en, this message translates to:
  /// **'Preparing notifications…'**
  String get statusWorking;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be prepared.'**
  String get statusFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @changeLanguageVoice.
  ///
  /// In en, this message translates to:
  /// **'Change language and voice'**
  String get changeLanguageVoice;

  /// No description provided for @openNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open device notification settings'**
  String get openNotificationSettings;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'This offline app chooses from messages bundled with the app. It has no account, ads, analytics, or network access.'**
  String get aboutBody;

  /// No description provided for @jokeNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fictional tip notice'**
  String get jokeNoticeTitle;

  /// No description provided for @jokeNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Some messages are intentionally made-up jokes, not factual, medical, legal, or safety advice.'**
  String get jokeNoticeBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'The app data could not be loaded.'**
  String get startupError;

  /// No description provided for @notificationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications are temporarily unavailable. You can continue using the app with notifications off.'**
  String get notificationUnavailable;

  /// No description provided for @errorCode.
  ///
  /// In en, this message translates to:
  /// **'Error code'**
  String get errorCode;

  /// No description provided for @notificationSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Messages from Mom'**
  String get notificationSwitchLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
