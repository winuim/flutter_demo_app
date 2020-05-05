import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedprefDeviceUUID {
  static const deviceUuidSaveKey = 'device-uuid';

  Future<void> save(String uuid) async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    // set value
    prefs.setString(deviceUuidSaveKey, uuid);
  }

  Future<String> read() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    // Try reading data from the Device UUID key. If it doesn't exist, return Generate a v4 (random) id.
    final uuid = prefs.getString(deviceUuidSaveKey) ?? Uuid().v4();
    // set value
    prefs.setString(deviceUuidSaveKey, uuid);
    return uuid;
  }

  Future<void> remove(String uuid) async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    // remove value
    prefs.remove(deviceUuidSaveKey);
  }
}
