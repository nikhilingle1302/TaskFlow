import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/app_preferences.dart';
import 'app_settings_state.dart';

export 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._preferences) : super(const AppSettingsInitial());

  final AppPreferences _preferences;

  Future<void> load() async {
    emit(
      AppSettingsLoaded(
        offlineMode: _preferences.offlineMode,
        simulateError: _preferences.simulateError,
      ),
    );
  }

  Future<void> setOfflineMode(bool value) async {
    await _preferences.setOfflineMode(value);
    final current = state;
    if (current is AppSettingsLoaded) {
      emit(current.copyWith(offlineMode: value));
    } else {
      await load();
    }
  }

  Future<void> setSimulateError(bool value) async {
    await _preferences.setSimulateError(value);
    final current = state;
    if (current is AppSettingsLoaded) {
      emit(current.copyWith(simulateError: value));
    } else {
      await load();
    }
  }
}
