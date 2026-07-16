import '../settings/app_settings.dart';

enum AppPhase {
  loading,
  languageSelection,
  voiceSelection,
  permissionExplanation,
  home,
  startupError,
}

enum NotificationPermissionState { unknown, granted, denied }

enum SchedulingState { idle, working, failed }

class AppViewState {
  const AppViewState({
    required this.phase,
    required this.settings,
    required this.permission,
    required this.scheduling,
    this.userVisibleError,
  });

  factory AppViewState.loading() => AppViewState(
    phase: AppPhase.loading,
    settings: AppSettings.defaults(),
    permission: NotificationPermissionState.unknown,
    scheduling: SchedulingState.idle,
  );

  final AppPhase phase;
  final AppSettings settings;
  final NotificationPermissionState permission;
  final SchedulingState scheduling;
  final String? userVisibleError;

  AppViewState copyWith({
    AppPhase? phase,
    AppSettings? settings,
    NotificationPermissionState? permission,
    SchedulingState? scheduling,
    String? userVisibleError,
    bool clearError = false,
  }) => AppViewState(
    phase: phase ?? this.phase,
    settings: settings ?? this.settings,
    permission: permission ?? this.permission,
    scheduling: scheduling ?? this.scheduling,
    userVisibleError: clearError
        ? null
        : (userVisibleError ?? this.userVisibleError),
  );
}
