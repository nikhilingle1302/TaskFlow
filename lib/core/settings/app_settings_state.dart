import 'package:equatable/equatable.dart';

abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

class AppSettingsLoaded extends AppSettingsState {
  const AppSettingsLoaded({
    required this.offlineMode,
    required this.simulateError,
  });

  final bool offlineMode;
  final bool simulateError;

  AppSettingsLoaded copyWith({
    bool? offlineMode,
    bool? simulateError,
  }) {
    return AppSettingsLoaded(
      offlineMode: offlineMode ?? this.offlineMode,
      simulateError: simulateError ?? this.simulateError,
    );
  }

  @override
  List<Object?> get props => [offlineMode, simulateError];
}
