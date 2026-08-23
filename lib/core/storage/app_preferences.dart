import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  bool get offlineMode => _prefs.getBool(AppConstants.keyOfflineMode) ?? false;

  bool get simulateError =>
      _prefs.getBool(AppConstants.keySimulateError) ?? false;

  Future<void> setOfflineMode(bool value) async {
    await _prefs.setBool(AppConstants.keyOfflineMode, value);
  }

  Future<void> setSimulateError(bool value) async {
    await _prefs.setBool(AppConstants.keySimulateError, value);
  }
}
