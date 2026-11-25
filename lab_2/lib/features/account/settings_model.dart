import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dark mode, the default region and the photo path, kept in
/// shared_preferences. [load] runs before `runApp`: no flash of the
/// wrong theme.
class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    this.dark = false,
    this.defaultRegion,
    this.photoPath,
  });

  static const _darkKey = 'darkMode';
  static const _regionKey = 'defaultRegion';
  static const _photoKey = 'photoPath';

  final SharedPreferencesAsync _prefs;
  bool dark;
  String? defaultRegion;
  String? photoPath;

  static Future<SettingsModel> load(SharedPreferencesAsync prefs) async {
    var photo = await prefs.getString(_photoKey);
    if (photo != null && !await File(photo).exists()) photo = null;
    return SettingsModel(
      prefs,
      dark: await prefs.getBool(_darkKey) ?? false,
      defaultRegion: await prefs.getString(_regionKey),
      photoPath: photo,
    );
  }

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
    await _prefs.setBool(_darkKey, value);
  }

  Future<void> setDefaultRegion(String? value) async {
    defaultRegion = value;
    notifyListeners();
    await _save(_regionKey, value);
  }

  Future<void> setPhoto(String? path) async {
    photoPath = path;
    notifyListeners();
    await _save(_photoKey, path);
  }

  Future<void> _save(String key, String? value) =>
      value == null ? _prefs.remove(key) : _prefs.setString(key, value);
}
