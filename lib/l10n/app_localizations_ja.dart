// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '母の一言';

  @override
  String get tagline => 'たまに、母から来たような一言が届きます。';

  @override
  String get chooseLanguage => '言語を選んでください';

  @override
  String get chooseVoice => '話し方を選んでください';

  @override
  String get japanese => '日本語';

  @override
  String get english => 'English';

  @override
  String get jaStandard => '標準語';

  @override
  String get jaKansai => '関西弁';

  @override
  String get enNeutral => 'Neutral English';

  @override
  String get enBritish => 'British English';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get selected => '選択済み';

  @override
  String get exampleJaStandard => '冷蔵庫、開ける前に何を取るか決めなさい。';

  @override
  String get exampleJaKansai => '傘持った？ 空がちょっと迷ってるで。';

  @override
  String get exampleEnNeutral =>
      'Bring a layer. Rooms have opinions about temperature.';

  @override
  String get exampleEnBritish =>
      'Take a brolly. The clouds look rather committed.';

  @override
  String get permissionTitle => '通知について';

  @override
  String get permissionTiming => '朝から夜まで、時刻を変えながら不定期に届きます。';

  @override
  String get permissionStop => '通知はいつでも停止できます。';

  @override
  String get permissionJokes => '冗談として作られた生活情報が含まれます。笑い話として受け取ってください。';

  @override
  String get allowNotifications => '通知を許可する';

  @override
  String get notNow => '今は許可しない';

  @override
  String get notificationHeading => '母からの通知';

  @override
  String get statusEnabled => '今日も、そのうち何か言ってきます。';

  @override
  String get statusStopped => '母からの通知は止まっています。';

  @override
  String get statusPermissionDenied => '端末で通知が許可されていません。';

  @override
  String get statusWorking => '通知を準備しています…';

  @override
  String get statusFailed => '通知を準備できませんでした。';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get voice => '話し方';

  @override
  String get changeLanguageVoice => '言語と話し方を変更';

  @override
  String get openNotificationSettings => '端末の通知設定を開く';

  @override
  String get aboutTitle => 'このアプリについて';

  @override
  String get aboutBody => 'アプリ内に収録した文章から選ぶ、オフラインのアプリです。アカウント、広告、分析、通信はありません。';

  @override
  String get jokeNoticeTitle => '冗談情報について';

  @override
  String get jokeNoticeBody => '一部は意図的に作られた冗談です。事実、医療、法律、安全に関する助言ではありません。';

  @override
  String get retry => 'もう一度試す';

  @override
  String get startupError => 'アプリのデータを読み込めませんでした。';

  @override
  String get notificationUnavailable =>
      '通知機能を一時的に利用できません。通知をオフにしたままアプリを利用できます。';

  @override
  String get errorCode => 'エラーコード';

  @override
  String get notificationSwitchLabel => '母からの通知';
}
