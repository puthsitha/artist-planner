import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc
    extends HydratedBloc<NotificationSettingsEvent, NotificationSettingsState> {
  NotificationSettingsBloc()
      : super(NotificationSettingsState.defaults()) {
    on<NotifReminderToggled>(_onToggle);
    on<NotifSlotTimeChanged>(_onTimeChanged);
    on<NotifSettingsReset>(_onReset);
  }

  void _onToggle(
    NotifReminderToggled event,
    Emitter<NotificationSettingsState> emit,
  ) {
    switch (event.kind) {
      case ReminderKind.emotion:
        emit(state.copyWith(emotionEnabled: event.enabled));
      case ReminderKind.monthlyReflection:
        emit(state.copyWith(monthlyReflectionEnabled: event.enabled));
      case ReminderKind.goalDue:
        emit(state.copyWith(goalDueEnabled: event.enabled));
    }
  }

  void _onTimeChanged(
    NotifSlotTimeChanged event,
    Emitter<NotificationSettingsState> emit,
  ) {
    switch (event.slot) {
      case ReminderSlotName.morning:
        emit(
          state.copyWith(
            morningHour: event.hour,
            morningMinute: event.minute,
          ),
        );
      case ReminderSlotName.afternoon:
        emit(
          state.copyWith(
            afternoonHour: event.hour,
            afternoonMinute: event.minute,
          ),
        );
      case ReminderSlotName.evening:
        emit(
          state.copyWith(
            eveningHour: event.hour,
            eveningMinute: event.minute,
          ),
        );
    }
  }

  void _onReset(
    NotifSettingsReset event,
    Emitter<NotificationSettingsState> emit,
  ) {
    emit(NotificationSettingsState.defaults());
  }

  @override
  NotificationSettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return NotificationSettingsState(
        emotionEnabled: (json['emotionEnabled'] as bool?) ?? true,
        monthlyReflectionEnabled:
            (json['monthlyReflectionEnabled'] as bool?) ?? true,
        goalDueEnabled: (json['goalDueEnabled'] as bool?) ?? true,
        morningHour: (json['morningHour'] as int?) ?? 8,
        morningMinute: (json['morningMinute'] as int?) ?? 0,
        afternoonHour: (json['afternoonHour'] as int?) ?? 13,
        afternoonMinute: (json['afternoonMinute'] as int?) ?? 0,
        eveningHour: (json['eveningHour'] as int?) ?? 20,
        eveningMinute: (json['eveningMinute'] as int?) ?? 0,
      );
    } on Exception catch (e) {
      log('NotificationSettingsBloc fromJson error: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(NotificationSettingsState state) {
    return {
      'emotionEnabled': state.emotionEnabled,
      'monthlyReflectionEnabled': state.monthlyReflectionEnabled,
      'goalDueEnabled': state.goalDueEnabled,
      'morningHour': state.morningHour,
      'morningMinute': state.morningMinute,
      'afternoonHour': state.afternoonHour,
      'afternoonMinute': state.afternoonMinute,
      'eveningHour': state.eveningHour,
      'eveningMinute': state.eveningMinute,
    };
  }
}
