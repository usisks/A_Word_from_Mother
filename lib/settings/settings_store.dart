import 'app_settings.dart';

abstract interface class SettingsStore {
  Future<AppSettings> read();
  Future<void> write(AppSettings settings);
  Future<void> clearRecentHistory();
}
