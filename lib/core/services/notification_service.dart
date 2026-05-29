import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notification "kind" — used to compute deterministic notification IDs so
/// that scheduling for the same goal/day/slot replaces the previous one and
/// can be cancelled by re-deriving the same id.
enum NotifKind {
  /// Daily emotion check-in at 8AM / 1PM / 8PM (slot 0 / 1 / 2).
  emotion,

  /// End-of-month reflection reminder (slot 0 / 1 / 2).
  monthlyReflection,

  /// Goal due-date reminder (slot 0 / 1 / 2).
  goalDue,
}

/// One slot in the daily reminder schedule (morning / afternoon / evening).
///
/// Times are caller-supplied — defaults provided for convenience but the
/// settings UI may override them.
class ReminderSlot {
  const ReminderSlot(this.index, this.hour, this.minute);

  final int index;
  final int hour;
  final int minute;

  static const defaultMorning = ReminderSlot(0, 8, 0);
  static const defaultAfternoon = ReminderSlot(1, 13, 0);
  static const defaultEvening = ReminderSlot(2, 20, 0);

  static const defaults = <ReminderSlot>[
    defaultMorning,
    defaultAfternoon,
    defaultEvening,
  ];
}

/// Channel identifiers (Android).
class _Channels {
  static const emotion = 'emotion_reminders';
  static const monthly = 'monthly_reflection_reminders';
  static const goal = 'goal_due_reminders';
}

/// Singleton wrapper around [FlutterLocalNotificationsPlugin] that owns all
/// scheduling logic for the app.
///
/// Schedule rules implemented here:
///  * [scheduleDailyEmotionReminders] — three repeating daily notifications
///    at 08:00 / 13:00 / 20:00 reminding the user to log an emotion.
///  * [scheduleMonthlyReflectionReminders] — on the last day of each month
///    schedule three one-shot reminders (08:00 / 13:00 / 20:00). Cancelled
///    individually as soon as the user saves a reflection. The next month's
///    reminders are scheduled lazily whenever the service is asked to refresh.
///  * [scheduleGoalDueReminders] — for every uncompleted goal whose [dueDate]
///    is in the future (or today, before 20:00), schedule three one-shot
///    reminders on the due date at the same three slots. Cancelled when a
///    goal is completed or deleted.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Must be called once before any other method (typically from `bootstrap`).
  Future<void> init() async {
    if (_initialized) return;

    // Configure timezone database so zonedSchedule works correctly.
    tz_data.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e) {
      log('NotificationService: failed to resolve local tz, '
          'falling back to UTC ($e)');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher_round');
    const iosInit = DarwinInitializationSettings(
      // We request permission explicitly via [requestPermissions] below so
      // that we can show the prompt at the right moment.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    _initialized = true;
  }

  /// Ask the user for notification permission.
  ///
  /// Safe to call multiple times — the OS will only prompt once.
  Future<bool> requestPermissions() async {
    if (!_initialized) await init();

    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios == null) return false;
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      // Use permission_handler for a reliable POST_NOTIFICATIONS system dialog
      // on Android 13+ (API 33+). flutter_local_notifications alone can skip
      // the dialog silently on some devices.
      final notifStatus = await Permission.notification.request();
      if (notifStatus.isPermanentlyDenied) {
        log('NotificationService: POST_NOTIFICATIONS permanently denied');
        return false;
      }

      // For exact alarms (Android 12+) — request best-effort via the plugin so
      // the coordinator can fall back to inexactAllowWhileIdle when denied.
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestExactAlarmsPermission();
      }

      // Samsung / Android 16: battery optimisation aggressively kills
      // AlarmManager callbacks while the app is in Doze mode.
      // Requesting the exemption here ensures notifications fire on time even
      // on Samsung One UI 7 devices. The OS shows a one-time system dialog.
      final batteryStatus =
          await Permission.ignoreBatteryOptimizations.status;
      if (!batteryStatus.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }

      return notifStatus.isGranted;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns true if the app can fire exact alarms on this device.
  ///
  /// On Android < 12 and on iOS this always returns true.
  /// On Android 12+ (API 31+) the user must grant the SCHEDULE_EXACT_ALARM
  /// permission via Settings → Apps → Special app access → Alarms & reminders.
  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.canScheduleExactNotifications() ?? false;
  }

  /// Schedules the three repeating daily emotion check-in reminders.
  ///
  /// Idempotent: cancels any previously scheduled emotion reminders first.
  /// If [enabled] is false this becomes a cancel-only operation.
  Future<void> scheduleDailyEmotionReminders({
    required bool enabled,
    required List<ReminderSlot> slots,
    required String title,
    required Map<int, String> bodyBySlot, // 0/1/2 -> localized body
  }) async {
    if (!_initialized) await init();

    // Clear any old emotion reminders so we don't pile up duplicates.
    await _cancelKind(NotifKind.emotion);

    if (!enabled) return;

    // Use alarmClock when we have exact-alarm permission (most reliable, fires
    // through Doze). Fall back to inexact if the user hasn't granted it yet —
    // the coordinator will re-schedule the moment the app resumes after the
    // user visits Settings.
    final scheduleMode = await _resolveScheduleMode();

    for (final slot in slots) {
      final id = _emotionNotifId(slot.index);
      final scheduled = _nextInstanceOf(slot.hour, slot.minute);

      await _plugin.zonedSchedule(
        id,
        title,
        bodyBySlot[slot.index] ?? '',
        scheduled,
        _detailsFor(NotifKind.emotion),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // repeat daily
        payload: 'emotion:${slot.index}',
      );
    }
  }

  /// Schedules the three end-of-month reflection reminders for the *current*
  /// calendar month if the last day is today or in the future.
  ///
  /// If [enabled] is false or [reflectionAlreadySaved] is true we cancel any
  /// pending reminders for this month instead of scheduling new ones.
  Future<void> scheduleMonthlyReflectionReminders({
    required bool enabled,
    required List<ReminderSlot> slots,
    required DateTime now,
    required bool reflectionAlreadySaved,
    required String title,
    required Map<int, String> bodyBySlot,
  }) async {
    if (!_initialized) await init();

    final lastDay = DateTime(now.year, now.month + 1, 0);
    // Always wipe this month's reminders first so toggles work either way.
    for (final slot in slots) {
      await _plugin.cancel(
        _reflectionNotifId(lastDay.month, lastDay.day, slot.index),
      );
    }

    if (!enabled || reflectionAlreadySaved) return;

    for (final slot in slots) {
      final scheduled = tz.TZDateTime(
        tz.local,
        lastDay.year,
        lastDay.month,
        lastDay.day,
        slot.hour,
        slot.minute,
      );

      // Skip slots whose time has already passed today.
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) continue;

      final id = _reflectionNotifId(lastDay.month, lastDay.day, slot.index);

      final scheduleMode = await _resolveScheduleMode();

      await _plugin.zonedSchedule(
        id,
        title,
        bodyBySlot[slot.index] ?? '',
        scheduled,
        _detailsFor(NotifKind.monthlyReflection),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reflection:${lastDay.year}-${lastDay.month}:${slot.index}',
      );
    }
  }

  /// (Re)schedules due-date reminders for a single goal.
  ///
  /// * If [enabled] is false, [isCompleted] is true, [dueDate] is null, or
  ///   [dueDate] is in the past, all pending reminders for this goal are
  ///   cancelled and nothing new is scheduled.
  /// * Otherwise, three one-shot reminders are scheduled on the due date at
  ///   the times specified by [slots] (slots whose time has already passed
  ///   today are skipped).
  Future<void> scheduleGoalDueReminders({
    required bool enabled,
    required List<ReminderSlot> slots,
    required String goalId,
    required String goalTitle,
    required DateTime? dueDate,
    required bool isCompleted,
    required String title,
    required Map<int, String> bodyBySlot,
  }) async {
    if (!_initialized) await init();

    // Always cancel any prior schedule for this goal so updates win.
    await cancelGoalDueReminders(goalId, slots: slots);

    if (!enabled || isCompleted || dueDate == null) return;

    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (due.isBefore(todayDate)) return;

    for (final slot in slots) {
      final scheduled = tz.TZDateTime(
        tz.local,
        due.year,
        due.month,
        due.day,
        slot.hour,
        slot.minute,
      );
      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) continue;

      final id = _goalNotifId(goalId, slot.index);
      final scheduleMode = await _resolveScheduleMode();

      await _plugin.zonedSchedule(
        id,
        title,
        (bodyBySlot[slot.index] ?? '').replaceAll('{title}', goalTitle),
        scheduled,
        _detailsFor(NotifKind.goalDue),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'goal:$goalId:${slot.index}',
      );
    }
  }

  /// Cancel all scheduled reminders for a single goal (used when a goal is
  /// completed or deleted). [slots] defaults to the canonical 3-slot layout —
  /// only the slot indices are used so it doesn't matter whether the times
  /// match the ones the goal was originally scheduled at.
  Future<void> cancelGoalDueReminders(
    String goalId, {
    List<ReminderSlot> slots = ReminderSlot.defaults,
  }) async {
    if (!_initialized) await init();
    for (final slot in slots) {
      await _plugin.cancel(_goalNotifId(goalId, slot.index));
    }
  }

  /// Cancel everything — useful for tests / sign-out.
  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Resolves the best [AndroidScheduleMode] for the current device.
  ///
  /// * [AndroidScheduleMode.alarmClock] — exact, bypasses Doze, shows an
  ///   alarm-clock icon. Requires SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM.
  /// * [AndroidScheduleMode.inexactAllowWhileIdle] — falls back gracefully
  ///   when the user has not yet granted exact-alarm permission. The OS fires
  ///   the notification within a short window around the scheduled time.
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final canExact = await canScheduleExactNotifications();
    return canExact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> _cancelKind(NotifKind kind) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (_kindFromId(p.id) == kind) {
        await _plugin.cancel(p.id);
      }
    }
  }

  NotificationDetails _detailsFor(NotifKind kind) {
    switch (kind) {
      case NotifKind.emotion:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _Channels.emotion,
            'Emotion check-ins',
            channelDescription: 'Daily reminders to log how you feel',
            // Raised from defaultImportance → high so Samsung One UI does not
            // silently suppress the notification in the status bar without
            // playing a sound (defaultImportance = no heads-up on Samsung).
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: _Channels.emotion,
          ),
        );
      case NotifKind.monthlyReflection:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _Channels.monthly,
            'Monthly reflection',
            channelDescription:
                'End-of-month reminders to write your reflection',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: _Channels.monthly,
          ),
        );
      case NotifKind.goalDue:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            _Channels.goal,
            'Goal due dates',
            channelDescription: 'Reminders for goals due today',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: _Channels.goal,
          ),
        );
    }
  }

  /// Compute the next [tz.TZDateTime] for a given (hour, minute) — today if
  /// the time is still in the future, otherwise tomorrow.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ---------------------------------------------------------------------------
  // Notification ID space
  //
  // Android & iOS both require a 32-bit integer ID. We carve up the space so
  // that each (kind, date, slot) triple is deterministic and conflict-free:
  //
  //   emotion:            0..99
  //   monthlyReflection:  100_000 + month*100 + day*10 + slot   (100k..199k)
  //   goalDue:            500_000 + (hash(goalId) & 0xFFFFF) * 10 + slot
  // ---------------------------------------------------------------------------

  int _emotionNotifId(int slot) => slot;

  int _reflectionNotifId(int month, int day, int slot) =>
      100000 + month * 100 + day * 10 + slot;

  int _goalNotifId(String goalId, int slot) {
    final hash = goalId.hashCode & 0xFFFFF; // 20 bits = ~1M values
    return 500000 + hash * 10 + slot;
  }

  NotifKind? _kindFromId(int id) {
    if (id >= 0 && id < 100) return NotifKind.emotion;
    if (id >= 100000 && id < 500000) return NotifKind.monthlyReflection;
    if (id >= 500000) return NotifKind.goalDue;
    return null;
  }

  // ---------------------------------------------------------------------------
  // Diagnostics (debug-only helpers)
  //
  // These do not change scheduling behaviour — they only inspect it. Use them
  // to figure out why a scheduled notification isn't firing on a real device
  // (almost always: exact-alarm denied -> inexact fallback -> Doze delays it,
  // or an OEM battery manager killing the alarm).
  // ---------------------------------------------------------------------------

  /// Reserved id outside every [NotifKind] range (emotion 0..99,
  /// reflection 100k..<500k, goal >=500k) so the test notification is never
  /// auto-cancelled by [_cancelKind] or the goal/reflection cancel paths.
  static const int _testNotifId = 99999;

  /// Builds a human-readable report explaining the current delivery state.
  ///
  /// Logs it via `dart:developer` [log] (so it shows in `flutter logs` /
  /// the IDE console) and also returns the string so a debug screen can show
  /// or copy it. Safe to call any time after [init].
  Future<String> diagnostics() async {
    if (!_initialized) await init();

    final b = StringBuffer()
      ..writeln('=== NotificationService diagnostics ===')
      ..writeln('platform:        ${Platform.operatingSystem}')
      ..writeln('local timezone:  ${tz.local.name}')
      ..writeln('now (local):     ${tz.TZDateTime.now(tz.local)}');

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final notifEnabled = await android?.areNotificationsEnabled();
      final canExact = await android?.canScheduleExactNotifications();
      final mode = await _resolveScheduleMode();

      b
        ..writeln('--- Android ---')
        ..writeln('notifications enabled: $notifEnabled '
            '(false => channel/app notifications are off in system settings)')
        ..writeln('can schedule EXACT alarms: $canExact '
            '(false => inexact fallback; Doze can delay/drop reminders)')
        ..writeln('resolved schedule mode: ${mode.name}')
        ..writeln('POST_NOTIFICATIONS:    '
            '${await Permission.notification.status}')
        ..writeln('SCHEDULE_EXACT_ALARM:  '
            '${await Permission.scheduleExactAlarm.status}')
        ..writeln('battery optimization ignored: '
            '${await Permission.ignoreBatteryOptimizations.status} '
            '(denied => OEM battery saver may kill alarms in the background)');

      final active = await android?.getActiveNotifications() ?? const [];
      b.writeln('active (currently shown): ${active.length}');
    } else if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final perms = await ios?.checkPermissions();
      b
        ..writeln('--- iOS ---')
        ..writeln('alert:  ${perms?.isAlertEnabled}')
        ..writeln('badge:  ${perms?.isBadgeEnabled}')
        ..writeln('sound:  ${perms?.isSoundEnabled}');
    }

    final pending = await _plugin.pendingNotificationRequests();
    b.writeln('--- pending (${pending.length}) ---');
    for (final p in pending) {
      b.writeln('  #${p.id} [${_kindFromId(p.id)?.name ?? 'other'}] '
          '"${p.title}"  payload=${p.payload}');
    }
    b.write('=======================================');

    final report = b.toString();
    log(report, name: 'NotificationService');
    return report;
  }

  /// Schedules a one-shot test notification [delay] from now (default 1 min)
  /// using the *exact same* code path as the real reminders, so it surfaces any
  /// real-device delivery problem end-to-end.
  ///
  /// To test properly: call this, then **background** the app (home button) and
  /// lock the screen — do NOT hot-restart or force-stop, both clear pending
  /// alarms. Returns the [tz.TZDateTime] it was scheduled for.
  Future<tz.TZDateTime> scheduleTestNotification({
    Duration delay = const Duration(minutes: 1),
  }) async {
    if (!_initialized) await init();

    final when = tz.TZDateTime.now(tz.local).add(delay);
    final mode = await _resolveScheduleMode();

    await _plugin.zonedSchedule(
      _testNotifId,
      'Test notification',
      'Fires at $when (mode: ${mode.name})',
      when,
      _detailsFor(NotifKind.emotion),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'test',
    );

    log('NotificationService: test notification scheduled for $when '
        '(mode ${mode.name})', name: 'NotificationService');
    return when;
  }

  /// Cancels the pending test notification scheduled by [scheduleTestNotification].
  Future<void> cancelTestNotification() => _plugin.cancel(_testNotifId);

  @visibleForTesting
  FlutterLocalNotificationsPlugin get pluginForTest => _plugin;
}
