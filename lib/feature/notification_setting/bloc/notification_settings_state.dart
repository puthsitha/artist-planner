part of 'notification_settings_bloc.dart';

class NotificationSettingsState extends Equatable {
  const NotificationSettingsState({
    required this.emotionEnabled,
    required this.monthlyReflectionEnabled,
    required this.goalDueEnabled,
    required this.morningHour,
    required this.morningMinute,
    required this.afternoonHour,
    required this.afternoonMinute,
    required this.eveningHour,
    required this.eveningMinute,
  });

  /// 8AM / 1PM / 8PM, all reminder kinds enabled.
  factory NotificationSettingsState.defaults() => const NotificationSettingsState(
        emotionEnabled: true,
        monthlyReflectionEnabled: true,
        goalDueEnabled: true,
        morningHour: 8,
        morningMinute: 0,
        afternoonHour: 13,
        afternoonMinute: 0,
        eveningHour: 20,
        eveningMinute: 0,
      );

  final bool emotionEnabled;
  final bool monthlyReflectionEnabled;
  final bool goalDueEnabled;

  final int morningHour;
  final int morningMinute;
  final int afternoonHour;
  final int afternoonMinute;
  final int eveningHour;
  final int eveningMinute;

  /// Convenience: returns (h, m) for a given slot name.
  (int hour, int minute) timeFor(ReminderSlotName slot) {
    switch (slot) {
      case ReminderSlotName.morning:
        return (morningHour, morningMinute);
      case ReminderSlotName.afternoon:
        return (afternoonHour, afternoonMinute);
      case ReminderSlotName.evening:
        return (eveningHour, eveningMinute);
    }
  }

  NotificationSettingsState copyWith({
    bool? emotionEnabled,
    bool? monthlyReflectionEnabled,
    bool? goalDueEnabled,
    int? morningHour,
    int? morningMinute,
    int? afternoonHour,
    int? afternoonMinute,
    int? eveningHour,
    int? eveningMinute,
  }) {
    return NotificationSettingsState(
      emotionEnabled: emotionEnabled ?? this.emotionEnabled,
      monthlyReflectionEnabled:
          monthlyReflectionEnabled ?? this.monthlyReflectionEnabled,
      goalDueEnabled: goalDueEnabled ?? this.goalDueEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      afternoonHour: afternoonHour ?? this.afternoonHour,
      afternoonMinute: afternoonMinute ?? this.afternoonMinute,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
    );
  }

  @override
  List<Object?> get props => [
        emotionEnabled,
        monthlyReflectionEnabled,
        goalDueEnabled,
        morningHour,
        morningMinute,
        afternoonHour,
        afternoonMinute,
        eveningHour,
        eveningMinute,
      ];
}
