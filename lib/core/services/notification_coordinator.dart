import 'package:artistplanner/core/services/notification_service.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/feature/notification_setting/bloc/notification_settings_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives [NotificationService] from app state.
///
///  * On first build it requests permission and (re)schedules everything.
///  * It listens to [GoalBloc] state so that whenever goals change
///    (added / completed / deleted / due-date edited / reflection saved) the
///    relevant notifications are rescheduled or cancelled.
///  * It listens to [NotificationSettingsBloc] so toggling reminders or
///    changing slot times also triggers a full re-schedule.
///  * Locale changes also trigger a re-schedule so the body language matches.
///  * On [AppLifecycleState.resume] it re-schedules so that exact-alarm
///    permission granted while the user was in Settings takes effect
///    immediately (Android 12+ SCHEDULE_EXACT_ALARM flow).
class NotificationCoordinator extends StatefulWidget {
  const NotificationCoordinator({required this.child, super.key});

  final Widget child;

  @override
  State<NotificationCoordinator> createState() =>
      _NotificationCoordinatorState();
}

class _NotificationCoordinatorState extends State<NotificationCoordinator> {
  Locale? _lastLocale;
  GoalState? _lastGoalState;
  bool _firstRunDone = false;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// Called when the app comes back to the foreground (e.g. after the user
  /// visits Settings to grant SCHEDULE_EXACT_ALARM on Android 12+).
  /// Re-schedules everything so the correct [AndroidScheduleMode] is used now
  /// that the permission may have changed.
  Future<void> _onAppResume() async {
    if (!_firstRunDone || !mounted) return;
    final l = AppLocalizations.of(context);
    final goalState = context.read<GoalBloc>().state;
    final settings = context.read<NotificationSettingsBloc>().state;
    await _rescheduleAll(l, goalState, settings);
    _lastGoalState = goalState;
  }

  Future<void> _bootstrapPermissions() async {
    await NotificationService.instance.requestPermissions();
  }

  List<ReminderSlot> _slotsFromSettings(NotificationSettingsState s) {
    return [
      ReminderSlot(0, s.morningHour, s.morningMinute),
      ReminderSlot(1, s.afternoonHour, s.afternoonMinute),
      ReminderSlot(2, s.eveningHour, s.eveningMinute),
    ];
  }

  Future<void> _rescheduleEmotion(
    AppLocalizations l,
    NotificationSettingsState s,
  ) async {
    await NotificationService.instance.scheduleDailyEmotionReminders(
      enabled: s.emotionEnabled,
      slots: _slotsFromSettings(s),
      title: l.notif_emotion_title,
      bodyBySlot: {
        0: l.notif_emotion_morning_body,
        1: l.notif_emotion_afternoon_body,
        2: l.notif_emotion_evening_body,
      },
    );
  }

  Future<void> _rescheduleMonthlyReflection(
    AppLocalizations l,
    GoalState goalState,
    NotificationSettingsState s,
  ) async {
    final now = DateTime.now();
    final hasReflection = goalState.reflectionFor(now.year, now.month) != null;
    await NotificationService.instance.scheduleMonthlyReflectionReminders(
      enabled: s.monthlyReflectionEnabled,
      slots: _slotsFromSettings(s),
      now: now,
      reflectionAlreadySaved: hasReflection,
      title: l.notif_reflection_title,
      bodyBySlot: {
        0: l.notif_reflection_morning_body,
        1: l.notif_reflection_afternoon_body,
        2: l.notif_reflection_evening_body,
      },
    );
  }

  Future<void> _rescheduleGoals(
    AppLocalizations l,
    GoalState goalState,
    NotificationSettingsState s, {
    GoalState? previous,
  }) async {
    final svc = NotificationService.instance;
    final slots = _slotsFromSettings(s);

    final currentIds = goalState.goals.map((g) => g.id).toSet();
    final previousIds =
        previous?.goals.map((g) => g.id).toSet() ?? const <String>{};

    // Cancel reminders for goals that have been deleted.
    for (final goneId in previousIds.difference(currentIds)) {
      await svc.cancelGoalDueReminders(goneId, slots: slots);
    }

    for (final goal in goalState.goals) {
      await svc.scheduleGoalDueReminders(
        enabled: s.goalDueEnabled,
        slots: slots,
        goalId: goal.id,
        goalTitle: goal.title,
        dueDate: goal.dueDate,
        isCompleted: goal.isCompleted,
        title: l.notif_goal_title,
        bodyBySlot: {
          0: l.notif_goal_morning_body('{title}'),
          1: l.notif_goal_afternoon_body('{title}'),
          2: l.notif_goal_evening_body('{title}'),
        },
      );
    }
  }

  Future<void> _rescheduleAll(
    AppLocalizations l,
    GoalState goalState,
    NotificationSettingsState s, {
    GoalState? previousGoal,
  }) async {
    await _rescheduleEmotion(l, s);
    await _rescheduleMonthlyReflection(l, goalState, s);
    await _rescheduleGoals(l, goalState, s, previous: previousGoal);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<GoalBloc, GoalState>(
          listenWhen: (prev, curr) => prev != curr,
          listener: (context, state) async {
            final settings = context.read<NotificationSettingsBloc>().state;
            await _rescheduleMonthlyReflection(l, state, settings);
            await _rescheduleGoals(
              l,
              state,
              settings,
              previous: _lastGoalState,
            );
            _lastGoalState = state;
          },
        ),
        BlocListener<NotificationSettingsBloc, NotificationSettingsState>(
          listenWhen: (prev, curr) => prev != curr,
          listener: (context, settings) async {
            final goalState = context.read<GoalBloc>().state;
            await _rescheduleAll(l, goalState, settings);
            _lastGoalState = goalState;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          // First-run bootstrap and locale-change handling.
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!_firstRunDone) {
              _firstRunDone = true;
              await _bootstrapPermissions();
              final goalState = context.read<GoalBloc>().state;
              final settings = context.read<NotificationSettingsBloc>().state;
              await _rescheduleAll(l, goalState, settings);
              _lastGoalState = goalState;
              _lastLocale = locale;
            } else if (_lastLocale != locale) {
              _lastLocale = locale;
              final goalState = context.read<GoalBloc>().state;
              final settings = context.read<NotificationSettingsBloc>().state;
              await _rescheduleAll(l, goalState, settings);
              _lastGoalState = goalState;
            }
          });
          return widget.child;
        },
      ),
    );
  }
}
