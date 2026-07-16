import 'package:flutter/services.dart';

class AndroidSettingsService {
  const AndroidSettingsService();
  static const _channel = MethodChannel('com.usisks.mothersword/settings');

  Future<void> openNotificationSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');
}
