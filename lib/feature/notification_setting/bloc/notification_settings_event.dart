part of 'notification_settings_bloc.dart';

enum ReminderKind { emotion, monthlyReflection, goalDue }

enum ReminderSlotName { morning, afternoon, evening }

sealed class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();

  @override
  List<Object?> get props => [];
}

class NotifReminderToggled extends NotificationSettingsEvent {
  const NotifReminderToggled({required this.kind, required this.enabled});

  final ReminderKind kind;
  final bool enabled;

  @override
  List<Object?> get props => [kind, enabled];
}

class NotifSlotTimeChanged extends NotificationSettingsEvent {
  const NotifSlotTimeChanged({
    required this.slot,
    required this.hour,
    required this.minute,
  });

  final ReminderSlotName slot;
  final int hour;
  final int minute;

  @override
  List<Object?> get props => [slot, hour, minute];
}

class NotifSettingsReset extends NotificationSettingsEvent {
  const NotifSettingsReset();
}
