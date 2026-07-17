# 「母の一言」Android MVP 詳細設計書

## 1. 工程と設計結果

### 現在の工程

**Android MVP 詳細設計**

### 次工程

1. リポジトリ作成
2. 仕様書配置
3. Flutterプロジェクト作成
4. 段階的実装
5. 自動テスト
6. Android実機テスト
7. 公開準備

### 詳細設計の総合判定

**実装着手可能。ただし、アプリIDと深夜遅延通知の扱いを実装開始前に確定する。**

---
## v0.2.0 product specification and implementation status

The confirmed v0.2.0 behavior below is implemented and approved for Release. Reviewer やまと approved the 160 new messages and reported the manual Android device gate as passed on 2026-07-17. The automated Android integration test was not run because no supported target was connected; the product owner explicitly waived that check for this Release after accepting the manual result.

| Area | v0.2.0 implemented requirement |
| --- | --- |
| Notification window | Let the user choose a start and end between 07:00 and 23:00 in 30-minute steps. Do not support crossing midnight; require at least three hours. |
| Last reservation | Reserve no later than 90 minutes before the chosen end time, to allow for inexact-alarm delay. |
| Frequency | Provide `quiet`, `normal`, and `chatty`. Keep a minimum 90-minute interval; when a window cannot fit the requested amount, reduce the count rather than the interval. |
| In-app message | Select one message per app launch and keep it unchanged for that launch. It must not affect notification history or notification scheduling. |
| Migration | Upgrade v0.1.0 settings without repeating onboarding. Use `scheduleVersion` to rebuild existing enabled schedules when the scheduling format changes. |
| Content target | Expand to at least 80 messages for each voice and at least 320 messages total. New or changed content requires human editorial, safety, language, and dialect review before Release. |

Class-level responsibilities, persistence keys, migration details, error handling, test cases, implementation phases, and prohibitions are defined in [V0.2.0 detailed design](V0.2.0_DETAILED_DESIGN.md). The feature-branch implementation matches these confirmed product requirements. This section does not retroactively change the released v0.1.0 behavior documented above.


# 2. 確定事項・仮決定・未決事項

## 2.1 確定事項

* AndroidのみをMVP対象とする
* Flutterを使用する
* ローカル完結とする
* サーバー、アカウント、広告、分析SDKを使用しない
* AIによるリアルタイム文章生成を行わない
* 通知文は監査済みJSONから選択する
* 通知時刻は厳密性よりランダム性と省電力を優先する
* 通知オン・オフ、言語、話し方のみ設定可能とする
* SQLiteを使用しない
* 通知アクションの選択履歴を保存しない
* 正確なアラーム権限を要求しない

## 2.2 仮決定

| 項目         | 仮決定                                         |
| ---------- | ------------------------------------------- |
| Flutter    | 3.44系Stable                                 |
| Dart       | 3.12系                                       |
| minSdk     | 24                                          |
| compileSdk | 36                                          |
| targetSdk  | 36                                          |
| Java       | 17                                          |
| 通知予約方式     | `flutter_local_notifications`のinexact alarm |
| 設定保存       | `SharedPreferencesAsync`                    |
| 状態管理       | Flutter標準の`ChangeNotifier`                  |
| 通知予約期間     | 30日分                                        |
| 最終予定時刻     | 20:30                                       |
| 通知Channel  | 1種類                                         |
| 通知重要度      | Default                                     |
| 英国英語のタイトル  | `Mum`                                       |
| 初期コンテンツ目標  | 各話し方80件以上                                   |
| ビルド可能最低数   | 各話し方40件以上                                   |

30日予約は、基本設計にあった3～7日予約からの変更である。7日分だけでは、アプリを一週間開かなかった利用者への通知が止まるため、WorkManagerなどを追加せずに体験を維持できる30日を採用する。

## 2.3 未決事項

| ID   | 内容                      | 推奨案                             | 決定期限     |
| ---- | ----------------------- | ------------------------------- | -------- |
| U-01 | Android applicationId   | `com.<developer>.mothersword`形式 | リポジトリ作成前 |
| U-02 | 英語アプリ名                  | `A Word from Mom`               | 公開準備前    |
| U-03 | OS遅延で22:00以降に発火する可能性    | 20:30を最終時刻とし、MVPではベストエフォート扱い    | 通知実装前    |
| U-04 | タイムゾーン変更後、アプリを一度も開かない場合 | 次回起動・復帰時に再構築する制約を許容             | 通知実装前    |
| U-05 | 最終的な通知アイコン              | 単色の吹き出しまたは母を示す抽象アイコン            | UI制作時    |

---

# 3. 採用技術

Flutter 3.44はAndroid API 24～36を正式な対応範囲としており、API 23以前は非対応であるため、`minSdk = 24`とする。2026年8月31日以降にGoogle Playへ新規アプリや更新を提出するには、Android 16、API 36以上を対象とする必要があるため、`compileSdk`と`targetSdk`は36へ固定する。

## 3.1 SDK

```yaml
flutter: "3.44.x stable"
dart: "3.12.x"
android:
  minSdk: 24
  compileSdk: 36
  targetSdk: 36
java: 17
```

Flutterのパッチバージョンは、リポジトリ作成時点の最新3.44系Stableを使用し、`.fvmrc`または開発文書へ固定する。

## 3.2 Runtime依存

| パッケージ                         | 設計時バージョン | 用途               |
| ----------------------------- | -------: | ---------------- |
| `flutter_local_notifications` |   22.0.1 | 通知表示、予約、取消、アクション |
| `shared_preferences`          |    2.5.5 | 設定と直近履歴          |
| `timezone`                    |   0.11.1 | タイムゾーン対応日時       |
| `flutter_timezone`            |    5.1.0 | 端末のIANAタイムゾーン取得  |
| `flutter_localizations`       |      SDK | UIローカライズ         |

`flutter_local_notifications` 22.0.1はFlutter 3.38.1以上を要求し、通知予約、アクション、取消、保留通知取得に対応している。`shared_preferences` 2.5.5はAndroid SDK 24以上に対応し、新規実装には従来APIではなく`SharedPreferencesAsync`または`SharedPreferencesWithCache`が推奨されている。

`timezone`は端末の現在タイムゾーンを取得しないため、端末からIANAタイムゾーン名を取得する`flutter_timezone`を併用する。

## 3.3 採用しないパッケージ

| 候補                         | 不採用理由                        |
| -------------------------- | ---------------------------- |
| Provider / Riverpod / Bloc | 単一Controllerで十分              |
| sqflite / Drift            | 保存データが少なく検索も不要               |
| permission_handler         | 通知パッケージと小さなMethodChannelで足りる |
| WorkManager                | バックグラウンド処理を増やしすぎる            |
| android_alarm_manager_plus | 通知パッケージと責務が重複する              |
| GetIt                      | 依存注入コンテナが不要                  |
| GoRouter                   | 4画面の単純遷移には過剰                 |
| JSON Schema実行時ライブラリ        | コンテンツはビルド前に検証する              |
| インターネット通信系パッケージ            | MVPでは通信しない                   |

---

# 4. Androidビルド設定

## 4.1 Gradle

`flutter_local_notifications`は通知予約の後方互換性のためCore Library Desugaringを必要とし、Java 17、`desugar_jdk_libs 2.1.4`、compileSdk 35以上を案内している。プラグイン側はAGP 8.11.1を使用しているため、Flutterテンプレートとの整合性を確認し、8.11.1以上を使用する。

```yaml
compileOptions:
  sourceCompatibility: Java 17
  targetCompatibility: Java 17
  coreLibraryDesugaring: true

dependencies:
  coreLibraryDesugaring: "com.android.tools:desugar_jdk_libs:2.1.4"
```

追加のWindowManager依存は、実際にdesugaring由来のクラッシュを再現した場合のみ追加する。先回りして追加しない。

## 4.2 権限

### 使用する権限

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

Android 13、API 33以降は`POST_NOTIFICATIONS`がランタイム権限であり、新規インストール時は通知が既定で無効となる。アプリ内説明の後、ユーザー操作を起点に要求する。

### 使用しない権限

```text
INTERNET
SCHEDULE_EXACT_ALARM
USE_EXACT_ALARM
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
ACCESS_NOTIFICATION_POLICY
USE_FULL_SCREEN_INTENT
位置情報
連絡先
カメラ
マイク
ストレージ
```

正確なアラームは、目覚まし時計やカレンダーなど厳密な時刻が中核となる用途向けである。Android 14では多くの新規アプリに`SCHEDULE_EXACT_ALARM`が既定許可されないため、本アプリでは要求しない。

## 4.3 Receiver

```xml
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />

<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>

<receiver
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"
    android:exported="false" />
```

これらは通知予約、端末再起動後の再予約、通知アクション処理に必要となる。

## 4.4 通知設定を開く処理

追加パッケージを入れず、`MainActivity.kt`のMethodChannelから次のIntentを開く。

```text
Settings.ACTION_APP_NOTIFICATION_SETTINGS
Settings.EXTRA_APP_PACKAGE
```

`ACTION_APP_NOTIFICATION_SETTINGS`はAPI 26以降で利用できる。API 24・25ではアプリ詳細設定画面へフォールバックする。

---

# 5. ディレクトリ構成

```text
mother_word/
├─ lib/
│  ├─ main.dart
│  │
│  ├─ app/
│  │  ├─ app_bootstrap.dart
│  │  ├─ mother_word_app.dart
│  │  ├─ app_settings_controller.dart
│  │  └─ app_view_state.dart
│  │
│  ├─ onboarding/
│  │  ├─ language_selection_page.dart
│  │  ├─ voice_selection_page.dart
│  │  └─ notification_permission_page.dart
│  │
│  ├─ home/
│  │  └─ home_page.dart
│  │
│  ├─ settings/
│  │  ├─ app_settings.dart
│  │  ├─ settings_store.dart
│  │  └─ shared_preferences_settings_store.dart
│  │
│  ├─ content/
│  │  ├─ mother_message.dart
│  │  ├─ content_loader.dart
│  │  └─ content_selector.dart
│  │
│  ├─ notifications/
│  │  ├─ notification_scheduler.dart
│  │  ├─ notification_gateway.dart
│  │  ├─ flutter_notification_gateway.dart
│  │  ├─ notification_constants.dart
│  │  └─ notification_callbacks.dart
│  │
│  ├─ platform/
│  │  ├─ time_zone_service.dart
│  │  └─ android_settings_service.dart
│  │
│  ├─ core/
│  │  ├─ clock.dart
│  │  └─ random_source.dart
│  │
│  └─ l10n/
│     ├─ app_ja.arb
│     └─ app_en.arb
│
├─ assets/
│  └─ content/
│     └─ messages.json
│
├─ tool/
│  └─ validate_content.dart
│
├─ test/
│  ├─ app/
│  ├─ settings/
│  ├─ content/
│  └─ notifications/
│
├─ integration_test/
│  └─ app_flow_test.dart
│
├─ android/
├─ AGENTS.md
├─ README.md
├─ CHANGELOG.md
└─ docs/
   ├─ PRODUCT_SPEC.md
   ├─ CONTENT_GUIDE.md
   └─ TEST_PLAN.md
```

Flutter標準のARBと生成ローカライズを使用し、通知本文JSONとは分離する。

---

# 6. データモデル

## 6.1 AppSettings

```dart
class AppSettings {
  final bool onboardingCompleted;
  final AppLanguage language;
  final MotherVoice voice;
  final bool notificationsEnabled;
  final List<String> recentContentIds;
  final List<String> recentCategories;
  final DateTime? lastScheduleRefreshAt;
  final String? lastTimeZoneId;
}
```

`lastTimeZoneId`は基本設計から追加する。端末のタイムゾーン変更を検出し、通知を再構築するために必要な最小項目である。

## 6.2 列挙値

```dart
enum AppLanguage {
  ja,
  en,
}

enum MotherVoice {
  jaStandard,
  jaKansai,
  enNeutral,
  enBritish,
}

enum MessageCategory {
  admonition,
  daily,
  fictionalGossip,
  fakeTip,
  caring,
  contextless,
  useful,
}
```

不正な言語と話し方の組み合わせは生成できないよう、`MotherVoice`から対応言語を取得する。

## 6.3 MotherMessage

```dart
class MotherMessage {
  final String id;
  final AppLanguage language;
  final MotherVoice voice;
  final MessageCategory category;
  final String body;
}
```

---

# 7. 設定保存仕様

## 7.1 保存キー

| キー                         | 型            | 初期値           |
| -------------------------- | ------------ | ------------- |
| `onboarding_completed`     | bool         | false         |
| `language`                 | String       | `ja`          |
| `voice`                    | String       | `ja_standard` |
| `notifications_enabled`    | bool         | false         |
| `recent_content_ids`       | List<String> | 空配列           |
| `recent_categories`        | List<String> | 空配列           |
| `last_schedule_refresh_at` | String       | 未設定           |
| `last_time_zone_id`        | String       | 未設定           |

## 7.2 最大保持数

* `recentContentIds`：30件
* `recentCategories`：2件

カテゴリー連続判定には直近2件だけあればよいため、3件以上保存しない。

## 7.3 保存実装

`SharedPreferencesAsync`を使用する。

`shared_preferences`は書き込みが戻った時点でディスク永続化を保証しないため、次の対策を行う。

1. すべての書き込みを`await`する
2. 重要な変更後は再読込して値を検証する
3. 読み込み不能時は通知をオフに倒す
4. 保存失敗時に通知オンと表示しない
5. 秘密情報や課金情報には使用しない

## 7.4 通知オン処理の順序

```text
通知権限を確認
  ↓
権限がなければユーザー操作から要求
  ↓
設定とコンテンツを検証
  ↓
通知予定を生成・予約
  ↓
全件成功
  ↓
notificationsEnabled = true を保存
  ↓
再読込して検証
```

保存検証に失敗した場合は全通知を取り消し、オフ状態に戻す。

## 7.5 通知オフ処理の順序

```text
UIを処理中表示
  ↓
予約通知を全取消
  ↓
取消成功
  ↓
notificationsEnabled = false を保存
  ↓
再読込して検証
```

取消に失敗した場合は一度だけ再試行する。二度とも失敗した場合、「通知を停止できませんでした」と表示し、オン状態を維持する。

---

# 8. 状態管理

外部状態管理パッケージを使用せず、`AppSettingsController extends ChangeNotifier`をアプリ全体で一つだけ生成する。

## 8.1 AppViewState

```dart
class AppViewState {
  final AppPhase phase;
  final AppSettings settings;
  final NotificationPermissionState permission;
  final SchedulingState scheduling;
  final String? userVisibleError;
}
```

```dart
enum AppPhase {
  loading,
  languageSelection,
  voiceSelection,
  permissionExplanation,
  home,
  startupError,
}

enum NotificationPermissionState {
  unknown,
  granted,
  denied,
}

enum SchedulingState {
  idle,
  working,
  failed,
}
```

## 8.2 Controller責務

* 初期化
* 設定読込
* 画面状態の決定
* 言語変更
* 話し方変更
* 通知オン・オフ
* 通知権限状態の再確認
* アプリ復帰時のタイムゾーン確認
* 通知予定の補充
* ユーザー向けエラー状態

UIは保存処理や通知APIを直接呼ばない。

---

# 9. 画面仕様

## 9.1 言語選択画面

### 表示

* アプリ名
* 短い説明
* 日本語カード
* Englishカード
* 次へボタン

### 動作

* 初期状態では未選択
* 選択後のみ「次へ」を有効化
* 選択はこの画面中の一時状態とし、「次へ」でControllerへ渡す
* 戻る操作でアプリ終了は許容する

### アクセシビリティ

* カード全体を48dp以上のタップ領域にする
* 選択状態を色だけでなくチェック表示と読み上げで示す
* 「日本語、選択済み」のようなSemanticsを付ける

## 9.2 話し方選択画面

### 日本語

* 標準語
* 関西弁

### 英語

* Neutral English
* British English

### 各カード

* 名称
* 1件の短い通知例
* 選択状態

### 動作

* 言語に属さない話し方は表示しない
* 戻ると前の言語選択へ戻る
* 次へで選択を保持し、通知説明へ進む

## 9.3 通知説明画面

### 表示

* 朝から夜まで不定期に通知する
* 通知はいつでも停止できる
* 冗談として作られた生活情報が含まれる
* 「通知を許可する」
* 「今は許可しない」

### 許可する

1. OS権限を要求
2. 許可された場合、通知予定を作成
3. 成功後に通知オンでオンボーディング完了
4. メイン画面へ遷移

### 今は許可しない

* `onboardingCompleted = true`
* `notificationsEnabled = false`
* メイン画面へ遷移
* OS権限ダイアログは表示しない

### 権限拒否

* オンボーディングは完了扱い
* 通知はオフ
* メイン画面に設定導線を表示

## 9.4 メイン画面

### 最上部固定領域

```text
母からの通知　[ ON / OFF ]
状態説明
```

### 状態表示

| 状態     | 表示               |
| ------ | ---------------- |
| 有効     | 今日も、そのうち何か言ってきます |
| ユーザー停止 | 母からの通知は止まっています   |
| 権限なし   | 端末で通知が許可されていません  |
| 処理中    | 通知を準備しています       |
| 失敗     | 通知を準備できませんでした    |

### 設定

* 言語
* 話し方
* 通知設定を開く
* アプリ説明
* 冗談情報に関する注意

言語または話し方の編集には、オンボーディングと同じ選択Widgetを再利用する。別の設定UIを重複実装しない。

---

# 10. 主要クラスと責務

## 10.1 AppSettingsController

```dart
Future<void> initialize();

Future<void> completeLanguageSelection(AppLanguage language);

Future<void> completeVoiceSelection(MotherVoice voice);

Future<void> completeOnboardingWithoutNotifications();

Future<void> requestPermissionAndEnableNotifications();

Future<void> setNotificationsEnabled(bool enabled);

Future<void> changeLanguage(AppLanguage language);

Future<void> changeVoice(MotherVoice voice);

Future<void> onAppResumed();

Future<void> retryScheduling();
```

## 10.2 SettingsStore

テスト差し替えのため、保存層だけは小さなinterfaceを持つ。

```dart
abstract interface class SettingsStore {
  Future<AppSettings> read();
  Future<void> write(AppSettings settings);
  Future<void> clearRecentHistory();
}
```

実装：

```text
SharedPreferencesSettingsStore
```

## 10.3 ContentLoader

```dart
Future<List<MotherMessage>> load();
```

責務：

* JSON Asset読込
* JSONからモデルへの変換
* 実行時の最低限の防御的検査
* 読み込み不能時の例外化

公開ビルドで不正JSONを許容する仕組みにはしない。CI検査が本来の防止手段である。

## 10.4 ContentSelector

```dart
MotherMessage? select({
  required List<MotherMessage> messages,
  required AppLanguage language,
  required MotherVoice voice,
  required List<String> recentIds,
  required List<String> recentCategories,
  required RandomSource random,
});
```

責務：

* 言語・話し方の抽出
* 直近30件の除外
* カテゴリー3連続防止
* 同言語フォールバック
* ランダム選択

## 10.5 NotificationGateway

プラグインを直接アプリロジックへ漏らさないための最小interface。

```dart
abstract interface class NotificationGateway {
  Future<void> initialize();

  Future<bool> areNotificationsEnabled();

  Future<bool> requestPermission();

  Future<void> schedule(ScheduledMotherNotification notification);

  Future<void> cancelAll();

  Future<int> pendingCount();

  Future<void> openSystemNotificationSettings();
}
```

実装：

```text
FlutterNotificationGateway
```

## 10.6 NotificationScheduler

```dart
Future<ScheduleSummary> rebuild({
  required AppSettings settings,
});

Future<ScheduleSummary> ensureSchedule({
  required AppSettings settings,
});

Future<void> cancelAll();
```

責務：

* タイムゾーン初期化
* 日別通知数決定
* 時刻生成
* ContentSelector呼出し
* 通知ID生成
* 30日分の予約
* 予約失敗の集約
* 設定履歴の更新

## 10.7 ClockとRandomSource

```dart
abstract interface class Clock {
  DateTime now();
}

abstract interface class RandomSource {
  int nextInt(int max);
}
```

日時・乱数ロジックを再現可能にするためのテスト用抽象化であり、一般的なUse Case層は作らない。

---

# 11. 通知文JSON

## 11.1 JSON例

```json
[
  {
    "id": "ja-standard-daily-0001",
    "language": "ja",
    "voice": "standard",
    "category": "daily",
    "body": "冷蔵庫、開ける前に何取るか決めなさい"
  }
]
```

## 11.2 JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "MotherMessageList",
  "type": "array",
  "items": {
    "type": "object",
    "additionalProperties": false,
    "required": [
      "id",
      "language",
      "voice",
      "category",
      "body"
    ],
    "properties": {
      "id": {
        "type": "string",
        "pattern": "^(ja-(standard|kansai)|en-(neutral|british))-(admonition|daily|fictional_gossip|fake_tip|caring|contextless|useful)-[0-9]{4}$"
      },
      "language": {
        "enum": ["ja", "en"]
      },
      "voice": {
        "enum": ["standard", "kansai", "neutral", "british"]
      },
      "category": {
        "enum": [
          "admonition",
          "daily",
          "fictional_gossip",
          "fake_tip",
          "caring",
          "contextless",
          "useful"
        ]
      },
      "body": {
        "type": "string",
        "minLength": 1,
        "maxLength": 90
      }
    },
    "allOf": [
      {
        "if": {
          "properties": {
            "language": { "const": "ja" }
          }
        },
        "then": {
          "properties": {
            "voice": { "enum": ["standard", "kansai"] }
          }
        }
      },
      {
        "if": {
          "properties": {
            "language": { "const": "en" }
          }
        },
        "then": {
          "properties": {
            "voice": { "enum": ["neutral", "british"] }
          }
        }
      }
    ]
  }
}
```

## 11.3 ID規則

```text
言語-話し方-カテゴリー-4桁連番
```

例：

```text
ja-standard-daily-0001
ja-kansai-admonition-0023
en-neutral-caring-0008
en-british-contextless-0014
```

一度公開したIDを別の文章へ再利用しない。

## 11.4 ビルド前検査

`dart run tool/validate_content.dart`で次を検査する。

* JSON構文
* 必須項目
* 未知フィールド
* ID重複
* 本文完全重複
* 空文字
* 90文字超過
* 言語と話し方の不正組み合わせ
* IDとフィールド値の不一致
* 未知カテゴリー
* 各話し方40件未満
* 禁止語候補
* 不正な制御文字

禁止語検査だけで安全性を保証しない。人間監査を通過したJSONだけをリポジトリへ入れる。

---

# 12. 通知文選択アルゴリズム

```text
1. 選択言語＋選択話し方で候補を抽出
2. 直近30件のIDを除外
3. 直近2件が同カテゴリーなら、そのカテゴリーを除外
4. 候補があればランダム選択
5. 候補がなければ、同言語の標準話者へ切替
6. 再度、重複・カテゴリー条件を適用
7. それでも候補がなければ、その通知予定を作らない
```

### 標準話者

| 言語  | フォールバック    |
| --- | ---------- |
| 日本語 | `standard` |
| 英語  | `neutral`  |

日本語から英語、英語から日本語へのフォールバックは禁止する。

### 履歴更新

通知が実際に表示されたかを追跡するDBは持たないため、通知文を**予約した時点**で直近履歴へ追加する。

設定変更で未表示通知が取り消された場合も、その文章は一時的に直近履歴へ残る。この差はMVPの簡素化として許容する。

---

# 13. 通知時刻生成アルゴリズム

## 13.1 時刻範囲

設計上の通知可能時間：

```text
8:00～22:00
```

実際の予約候補時間：

```text
8:00～20:30
```

20:30以降を予約しないことで、通常時のinexact alarm遅延に対して90分以上の余裕を持たせる。

Androidのinexact alarmは指定時刻より前には発火しない一方、Android 12以降では通常でも最大1時間程度遅れる可能性があり、Dozeやバッテリーセーバー下ではさらに遅れる可能性がある。

## 13.2 日別件数

```dart
count = random.nextInt(3) + 2;
```

結果：

* 2件
* 3件
* 4件

各件数は均等確率とする。

## 13.3 90分間隔を保証する方式

抽選再試行を使わず、次の方式で必ず条件を満たす。

```text
開始 = 8:00
終了 = 20:30
全幅 = 750分
最低間隔 = 90分
件数 = n

余白 = 750 - 90 × (n - 1)

0～余白からn個の乱数を生成
乱数を昇順に並べる

時刻[i] = 8:00 + 乱数[i] + 90 × i
```

これにより：

* すべて8:00～20:30
* 隣接通知は90分以上
* 再抽選ループなし
* 固定乱数による再現テストが可能

## 13.4 初回設定当日

現在時刻から30分後を最初の候補開始時刻とする。

```text
earliest = max(現在時刻＋30分, 8:00)
latest = 20:30
```

残り時間により次のようにする。

| 予約可能枠 |       当日件数 |
| ----: | ---------: |
|     0 |    当日は通知なし |
|     1 |         1件 |
|   2以上 | 可能な範囲で2～4件 |

「1日2～4件」は一日全体を予約できる翌日以降へ適用する。

## 13.5 予約期間

* 当日を含む30日
* 最大120件
* アプリ起動時に残り7日未満なら全再構築
* 保留通知数が想定より大幅に少ない場合も再構築
* 設定変更時は期間に関係なく全再構築

一部メーカーはバックグラウンドアラームを独自に抑制する場合があり、プラグインもXiaomiやHuaweiなどの機種差について注意を示している。実機テストを必須とする。

---

# 14. 通知予約方式

```dart
AndroidScheduleMode.inexactAllowWhileIdle
```

これはおおよその時刻で、低電力アイドル中にも実行可能なモードである。正確なアラーム権限は不要となる。

日時は`TZDateTime`で生成し、`zonedSchedule`を使用する。`flutter_local_notifications`も、DST問題を避けるためタイムゾーン付きスケジュールを推奨している。

## 14.1 タイムゾーン初期化

```text
timezoneのデータベースを初期化
  ↓
flutter_timezoneで端末のIANA IDを取得
  ↓
tz.setLocalLocation()
  ↓
lastTimeZoneIdと比較
  ↓
変更されていれば全通知再構築
```

通常版の`latest.dart`を使用する。10年版は小さいが、将来5年までしか収録しないため採用しない。

## 14.2 タイムゾーン変更の制約

アプリ起動時とフォアグラウンド復帰時に変更を検出する。

端末のタイムゾーン変更後、アプリを一度も開かない状態では、既存予約が旧タイムゾーン基準で動作する可能性がある。

MVPでは専用ネイティブReceiverや常駐処理を追加せず、この制約を既知事項として扱う。

---

# 15. 通知Channel

```yaml
id: "mother_messages_v1"
name_ja: "母からの一言"
name_en: "Messages from Mom"
description_ja: "母から届いたような一言を表示します"
description_en: "Shows occasional messages from Mom"
importance: "default"
priority: "default"
sound: "system default"
vibration: true
showBadge: false
bypassDnd: false
```

Channelは1種類だけ作成する。

AndroidではChannel作成後に重要度や通知動作をアプリ側から変更できないため、将来動作を変更する場合は`mother_messages_v2`のように新しいIDを使う。名前と説明は後から変更可能である。

---

# 16. 通知Payload

## 16.1 通知ID

```text
yyyyMMdd × 10 + slotIndex
```

例：

```text
20260716 × 10 + 2
= 202607162
```

* 日付ごとに一意
* 1日最大4件
* 32bit符号付き整数の範囲内
* 同じ日の再構築では同じIDを再利用できる
* 古い予約が残った場合も上書きしやすい

## 16.2 Payload

```json
{
  "v": 1,
  "type": "mother_message",
  "contentId": "ja-standard-daily-0001"
}
```

個人情報、設定内容、通知本文はPayloadへ入れない。

## 16.3 タイトル

| 話し方             | タイトル |
| --------------- | ---- |
| 日本語・標準語         | 母    |
| 日本語・関西弁         | 母    |
| Neutral English | Mom  |
| British English | Mum  |

---

# 17. 通知アクション

## 17.1 ID

```text
ack_huh
ack_okay
```

## 17.2 表示名

| 言語  | ack_huh | ack_okay |
| --- | ------- | -------- |
| 日本語 | へー      | おっけ      |
| 英語  | Huh     | Okay     |

## 17.3 AndroidNotificationAction

```dart
AndroidNotificationAction(
  'ack_huh',
  localizedHuh,
  showsUserInterface: false,
  cancelNotification: true,
);

AndroidNotificationAction(
  'ack_okay',
  localizedOkay,
  showsUserInterface: false,
  cancelNotification: true,
);
```

`showsUserInterface = false`によりユーザー画面を開かず、`cancelNotification = true`により選択した通知を消す。

## 17.4 バックグラウンドコールバック

```dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // MVPでは記録・返信・画面表示を行わない。
}
```

通知アクションはアプリ終了中にバックグラウンドIsolateを起動する場合があるため、トップレベル関数と`vm:entry-point`を使用する。

## 17.5 通知本文タップ

本文タップ時のみメイン画面を開く。

* 起動中：Homeへ遷移
* バックグラウンド：Homeへ復帰
* 終了中：起動後にHomeを表示
* 通知アクション：画面を開かない

---

# 18. 処理フロー

## 18.1 アプリ起動

```text
Flutter初期化
  ↓
通知プラグイン初期化
  ↓
タイムゾーン初期化
  ↓
コンテンツ読込
  ↓
設定読込
  ↓
通知許可状態取得
  ↓
初回設定未完了？
  ├─ はい → 言語選択
  └─ いいえ
        ↓
    タイムゾーン変更確認
        ↓
    通知オンかつ許可あり？
        ├─ はい → 予定残数確認・必要なら再構築
        └─ いいえ → Home
```

## 18.2 言語変更

```text
新言語を選択
  ↓
対応する標準話者を一時設定
  ↓
話し方を選択
  ↓
設定保存
  ↓
通知オン？
  ├─ いいえ → UI更新
  └─ はい
       ↓
    全通知取消
       ↓
    新言語・話し方で再予約
       ↓
    成功 → UI更新
    失敗 → 通知オフ＋エラー表示
```

## 18.3 通知オフ

```text
スイッチ操作
  ↓
処理中表示
  ↓
全通知取消
  ↓
取消成功？
  ├─ はい → オフ保存
  └─ いいえ
       ↓
    1回再試行
       ↓
    再失敗 → オン維持＋エラー
```

## 18.4 端末再起動

プラグインのBootReceiverが保存済み予定を再登録する。

次回アプリ起動時には、保留件数とタイムゾーンを再検査する。

## 18.5 アプリ更新

`MY_PACKAGE_REPLACED`を受けてプラグインが予定を再登録する。コンテンツJSON更新後は、初回起動時に全予定を再構築して新しい文章セットを使用する。

---

# 19. エラー設計

## 19.1 エラーコード

| コード                        | 内容       | ユーザー表示            |
| -------------------------- | -------- | ----------------- |
| `settings_read_failed`     | 設定読込失敗   | 設定を読み込めませんでした     |
| `settings_write_failed`    | 設定保存失敗   | 設定を保存できませんでした     |
| `notification_init_failed` | 通知初期化失敗  | 通知を準備できませんでした     |
| `permission_denied`        | 通知権限なし   | 端末で通知を許可してください    |
| `schedule_failed`          | 通知予約失敗   | 通知を準備できませんでした     |
| `cancel_failed`            | 通知取消失敗   | 通知を停止できませんでした     |
| `content_load_failed`      | JSON読込失敗 | アプリデータを読み込めませんでした |
| `content_empty`            | 候補不足     | 原則表示しない           |
| `timezone_failed`          | TZ取得失敗   | 通知を準備できませんでした     |

## 19.2 安全側の初期値

設定読込に失敗した場合：

```yaml
onboardingCompleted: false
notificationsEnabled: false
language: ja
voice: jaStandard
recentContentIds: []
recentCategories: []
```

通知を勝手にオンへ復旧しない。

## 19.3 ログ

* `debugPrint`または`dart:developer`を使用
* 外部送信しない
* 通知本文を必要以上にログへ残さない
* Releaseでは機密性のないエラーコードのみ
* 分析SDKやクラッシュ送信SDKを追加しない

---

# 20. アクセシビリティ

* 操作領域は原則48dp以上
* 通知状態を色だけで表現しない
* スイッチに「母からの通知、オン」などのSemanticsを付与
* 読み上げ順を画面表示順に合わせる
* OS文字サイズ200%でも主要操作を隠さない
* ボタン文字を1行固定にしない
* 日本語と英語で文字切れを確認する
* エラー表示は母親口調にしない
* 通知例は装飾として扱わず読み上げ可能にする
* 画面回転時も選択状態を維持する

---

# 21. 自動テスト

## 21.1 単体テスト

| ID     | テスト                |
| ------ | ------------------ |
| UT-001 | 通知件数が2～4件          |
| UT-002 | すべて8:00～20:30      |
| UT-003 | 隣接通知が90分以上         |
| UT-004 | 固定乱数で同じ結果          |
| UT-005 | 当日の過去時刻を選ばない       |
| UT-006 | 20:30以降は当日予約しない    |
| UT-007 | IDが日付・スロットごとに一意    |
| UT-008 | 直近30件を選ばない         |
| UT-009 | 同一カテゴリーを3回連続させない   |
| UT-010 | 日本語は標準語へフォールバック    |
| UT-011 | 英語はNeutralへフォールバック |
| UT-012 | 異言語へフォールバックしない     |
| UT-013 | 候補不足時はnull         |
| UT-014 | 不正な言語・話し方を拒否       |
| UT-015 | 履歴を30件へ切り詰める       |
| UT-016 | カテゴリー履歴を2件へ切り詰める   |
| UT-017 | 設定保存・復元            |
| UT-018 | 不正設定で通知オフへ復旧       |
| UT-019 | タイムゾーン変更を検出        |
| UT-020 | 通知予約失敗を集約          |

## 21.2 Widgetテスト

| ID     | テスト             |
| ------ | --------------- |
| WT-001 | 初回起動で言語選択       |
| WT-002 | 未選択時に次へ無効       |
| WT-003 | 言語に対応する話し方だけ表示  |
| WT-004 | 通知説明後に権限要求      |
| WT-005 | 今は許可しないでHomeへ進む |
| WT-006 | Home最上部に通知スイッチ  |
| WT-007 | 権限なし状態を表示       |
| WT-008 | 設定画面導線を表示       |
| WT-009 | 言語変更後に話し方を再選択   |
| WT-010 | 処理中は連続操作を防止     |
| WT-011 | 文字サイズ200%で操作可能  |
| WT-012 | Semanticsラベル確認  |

## 21.3 Integrationテスト

* 初回設定から通知予約まで
* 通知拒否からHomeまで
* 通知オンから予定作成まで
* 通知オフから全取消まで
* 言語変更から全再予約まで
* 話し方変更から全再予約まで
* 通知タップでHomeを開く
* アクションでは画面を開かない
* 設定保存失敗時にオンへしない
* タイムゾーン変更後に再構築する

---

# 22. Android実機テスト

## 22.1 対象

優先端末：

* Xiaomi 14T Pro
* Android 13相当端末またはエミュレータ
* Android 14
* Android 15
* Android 16

Flutter 3.44が正式にサポートするAndroid API 24～36を対象とし、少なくとも通知権限導入前後と最新OSで検証する。

## 22.2 実機ケース

| ID     | 内容                  |
| ------ | ------------------- |
| DT-001 | 新規インストール            |
| DT-002 | 通知許可                |
| DT-003 | 通知拒否                |
| DT-004 | OS設定から許可変更          |
| DT-005 | アプリ終了中の通知           |
| DT-006 | 画面ロック中の通知           |
| DT-007 | 2つの通知アクション          |
| DT-008 | アクションでアプリが開かない      |
| DT-009 | 本文タップでHomeを開く       |
| DT-010 | 通知オフ後に届かない          |
| DT-011 | 端末再起動後の再登録          |
| DT-012 | アプリ更新後の再登録          |
| DT-013 | バッテリーセーバー           |
| DT-014 | Xiaomiの自動起動・省電力制限   |
| DT-015 | 20:30予定の実発火時刻       |
| DT-016 | 22:00以降の遅延発火有無      |
| DT-017 | タイムゾーン変更            |
| DT-018 | 日付変更                |
| DT-019 | 通知ChannelをOS側で無効化   |
| DT-020 | Releaseビルドで通知アイコン表示 |

---

# 23. 実装工程

## Phase 1：Flutter基盤

### 作業

* Flutterプロジェクト作成
* SDK固定
* Android SDK設定
* lints設定
* ローカライズ生成
* ドキュメント配置

### 完了条件

* `flutter analyze`成功
* 日本語・英語を切り替えられる
* Android API 24エミュレータで起動
* API 36でビルド成功

---

## Phase 2：設定保存と状態管理

### 作業

* AppSettings
* SettingsStore
* SharedPreferencesAsync実装
* AppSettingsController
* 初期化・安全復旧

### 完了条件

* 設定単体テスト成功
* 不正データで通知オフへ復旧
* 外部状態管理パッケージなし

---

## Phase 3：オンボーディング

### 作業

* 言語選択
* 話し方選択
* 通知説明
* 初回状態遷移

### 完了条件

* Widgetテスト成功
* 戻る・再起動で状態矛盾なし
* 文字サイズ拡大で操作可能

---

## Phase 4：コンテンツ

### 作業

* JSON Schema
* MotherMessage
* ContentLoader
* ContentSelector
* 検証ツール

### 完了条件

* 不正JSONで検証失敗
* 重複防止テスト成功
* カテゴリー連続防止成功
* 各話し方40件以上

---

## Phase 5：時刻生成

### 作業

* Clock
* RandomSource
* 時刻生成
* 30日予定生成
* 通知ID生成

### 完了条件

* 2～4件
* 90分間隔
* 8:00～20:30
* 固定乱数テスト成功

---

## Phase 6：Android通知

### 作業

* 通知プラグイン
* Channel
* 権限
* zonedSchedule
* Payload
* アクション
* 通知タップ

### 完了条件

* API 33以上で権限要求
* 2アクション表示
* アクション後に通知消去
* アクションで画面を開かない
* 本文タップでHomeを開く
* 正確アラーム権限なし

---

## Phase 7：再起動と設定変更

### 作業

* BootReceiver設定
* 全取消
* 言語・話し方変更時の再予約
* 起動時補修
* タイムゾーン確認

### 完了条件

* 再起動後も保留通知が存在
* 通知オフ後に保留通知ゼロ
* 設定変更後に旧言語通知なし

---

## Phase 8：Home

### 作業

* 状態カード
* 通知スイッチ
* 言語・話し方編集
* OS設定導線
* エラー表示
* 注意事項

### 完了条件

* 通知停止が画面最上部
* 権限状態を区別
* 処理中の多重操作なし
* UIテスト成功

---

## Phase 9：総合テスト

### 作業

* 単体
* Widget
* Integration
* Releaseビルド
* コンテンツ検査

### 完了条件

```text
flutter analyze
flutter test
flutter test integration_test
dart run tool/validate_content.dart
flutter build appbundle --release
```

すべて成功する。

---

## Phase 10：実機・公開準備

### 作業

* Xiaomi 14T Pro実機検証
* 複数Androidバージョン検証
* README更新
* CHANGELOG更新
* プライバシー説明
* ストア用資料

### 完了条件

* 必須実機ケース合格
* 既知制約を文書化
* 不要な権限なし
* Release AAB生成成功

---

# 24. 要件対応表

| 要件         | 詳細設計                          |
| ---------- | ----------------------------- |
| 日本語・英語     | ARB＋Content JSON              |
| 複数の話し方     | MotherVoice                   |
| 初回言語選択     | LanguageSelectionPage         |
| 次に話し方選択    | VoiceSelectionPage            |
| 通知許可       | NotificationPermissionPage    |
| 朝から夜       | 8:00～20:30予定                  |
| 深夜抑止       | 早めの最終時刻＋inexact制約試験           |
| ランダム通知     | RandomSource＋時刻生成             |
| 2～4件       | 日別件数抽選                        |
| 90分以上      | 数式による時刻生成                     |
| へー・おっけ     | AndroidNotificationAction     |
| 選択後に消去     | cancelNotification            |
| アプリを開かない   | showsUserInterface=false      |
| 通知オン・オフ    | Home＋Controller               |
| オフ時全取消     | NotificationGateway.cancelAll |
| 再起動後の復元    | BootReceiver                  |
| 直近30件除外    | recentContentIds              |
| 3カテゴリー連続防止 | recentCategories              |
| オフライン      | Asset JSON＋ローカル通知             |
| 不要権限禁止     | Manifest監査                    |
| 未監査文禁止     | ビルド前検証＋人間監査                   |

---

# 25. 厳しい先輩プログラマーによる自己監査

## 25.1 過剰な抽象化

### 判定：合格

interfaceは以下のテスト境界に限定した。

* SettingsStore
* NotificationGateway
* Clock
* RandomSource

単純操作専用Use Case、Repository、DIコンテナは作らない。

## 25.2 不要なパッケージ

### 判定：合格

Runtime依存は通知、保存、タイムゾーンだけである。

Provider、Riverpod、SQLite、WorkManager、permission_handlerを追加していない。

## 25.3 重複状態

### 判定：合格

永続設定とUI状態は`AppSettingsController`だけが管理する。

各画面が独自に通知オン・オフを保持しない。

## 25.4 30日予約

### 判定：妥当

バックグラウンド補充サービスを追加するより簡単で、最大120件に収まる。

ただし、非常に長期間アプリを開かない場合は30日後に通知が止まる。これはローカル完結MVPの既知制約とする。

## 25.5 深夜通知

### 判定：要注意

正確なアラームを使わず、OSが通知を遅延させる以上、22:00以降の表示を100%保証できない。

設計では：

* 最終予定時刻を20:30へ前倒し
* 通常時に90分以上の余裕を確保
* Xiaomi実機を含む省電力試験
* 22:00以降の遅延有無を記録

で可能性を下げる。

絶対保証が必要になった場合は、カスタムAndroid Receiverまたは別のバックグラウンド方式を再設計する。それはMVPの追加作業として別途判断する。

## 25.6 保存方式

### 判定：条件付き合格

`shared_preferences`は重要データ向けではないが、本アプリの保存内容は再生成可能であり、書き込み検証と安全側初期値で対応可能である。

SQLiteへ戻す必要はない。

## 25.7 MVP外機能

### 判定：合格

以下は含まれていない。

* iOS
* 履歴画面
* お気に入り
* 時刻・頻度設定
* AI生成
* サーバー
* オンライン更新
* 分析
* アカウント

---

# 26. 詳細設計完了判定

## 完了

* 技術構成
* SDK
* パッケージ
* Android権限
* ディレクトリ
* 画面
* 状態
* クラス責務
* 保存形式
* JSON Schema
* 選択処理
* 時刻生成
* 通知Channel
* Payload
* アクション
* エラー
* テスト
* 実装工程
* 完了条件

## 実装開始前に確定するもの

1. applicationId
2. 英語アプリ名
3. OS遅延による22:00以降通知をベストエフォートとして許容するか
4. 初期収録する通知文の実数
5. 通知アイコンの正本
