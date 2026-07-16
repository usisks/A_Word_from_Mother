import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class TimeZoneService {
  bool _initialized = false;

  Future<String> initialize() async {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
    final info = await FlutterTimezone.getLocalTimezone();
    final identifier = info.identifier;
    tz.setLocalLocation(tz.getLocation(identifier));
    return identifier;
  }
}
