import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/notification_setting/bloc/notification_settings_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: NotificationSettingsPage(key: key));

  @override
  Widget build(BuildContext context) => const _NotificationSettingsView();
}

/// Top-level page layout. Intentionally light on state — the scroll view and
/// every section header live here so they aren't rebuilt when a single toggle
/// flips. Only the toggle/time-tile widgets read bloc state, via [BlocSelector].
class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isGlassUI = context.watch<ThemeBloc>().state.isGlassUI;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.transparent,
        title: Text(
          l10n.notifications_title,
          style: TextStyle(color: AppColors.white),
        ),
      ),
      // The page is pushed onto the root navigator (see app_route.dart), so
      // the bottom-nav bar is not visible here. We only need normal safe-area
      // bottom padding, not kBottomNavBarHeight.
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          // PrimaryScrollController gives the framework a stable controller
          // and avoids surprises when the page is pushed/popped.
          primary: true,
          padding: const EdgeInsets.fromLTRB(
            Spacing.normal,
            Spacing.s,
            Spacing.normal,
            Spacing.l1,
          ),
          child: LiquidGlassLayer(
            fake: !isGlassUI,
            settings: LiquidGlassSettings(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.s,
                    Spacing.s,
                    Spacing.s,
                    Spacing.normal,
                  ),
                  child: Text(
                    l10n.notifications_subtitle,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                _SectionHeader(title: l10n.notif_section_reminders),
                const SizedBox(height: Spacing.s),
                _EmotionToggleTile(
                  label: l10n.notif_emotion_label,
                  caption: l10n.notif_emotion_caption,
                ),
                const SizedBox(height: Spacing.m),
                _ReflectionToggleTile(
                  label: l10n.notif_reflection_label,
                  caption: l10n.notif_reflection_caption,
                ),
                const SizedBox(height: Spacing.m),
                _GoalToggleTile(
                  label: l10n.notif_goal_label,
                  caption: l10n.notif_goal_caption,
                ),
                const SizedBox(height: Spacing.l),
                _SectionHeader(title: l10n.notif_section_times),
                const SizedBox(height: Spacing.s),
                _MorningTimeTile(label: l10n.notif_morning_time),
                const SizedBox(height: Spacing.m),
                _AfternoonTimeTile(label: l10n.notif_afternoon_time),
                const SizedBox(height: Spacing.m),
                _EveningTimeTile(label: l10n.notif_evening_time),
                const SizedBox(height: Spacing.l1),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context
                        .read<NotificationSettingsBloc>()
                        .add(const NotifSettingsReset()),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(l10n.notif_reset_defaults),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle tiles
// ---------------------------------------------------------------------------

class _EmotionToggleTile extends StatelessWidget {
  const _EmotionToggleTile({required this.label, required this.caption});
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      bool
    >(
      selector: (s) => s.emotionEnabled,
      builder: (context, value) => _GlassToggleTile(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFFF8FB1),
        title: label,
        subtitle: caption,
        value: value,
        onChanged: (v) => context.read<NotificationSettingsBloc>().add(
          NotifReminderToggled(kind: ReminderKind.emotion, enabled: v),
        ),
      ),
    );
  }
}

class _ReflectionToggleTile extends StatelessWidget {
  const _ReflectionToggleTile({required this.label, required this.caption});
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      bool
    >(
      selector: (s) => s.monthlyReflectionEnabled,
      builder: (context, value) => _GlassToggleTile(
        icon: Icons.calendar_view_month_rounded,
        iconColor: const Color(0xFF8FE0FF),
        title: label,
        subtitle: caption,
        value: value,
        onChanged: (v) => context.read<NotificationSettingsBloc>().add(
          NotifReminderToggled(
            kind: ReminderKind.monthlyReflection,
            enabled: v,
          ),
        ),
      ),
    );
  }
}

class _GoalToggleTile extends StatelessWidget {
  const _GoalToggleTile({required this.label, required this.caption});
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      bool
    >(
      selector: (s) => s.goalDueEnabled,
      builder: (context, value) => _GlassToggleTile(
        icon: Icons.flag_rounded,
        iconColor: const Color(0xFFFFD58F),
        title: label,
        subtitle: caption,
        value: value,
        onChanged: (v) => context.read<NotificationSettingsBloc>().add(
          NotifReminderToggled(kind: ReminderKind.goalDue, enabled: v),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time tiles
// ---------------------------------------------------------------------------

class _MorningTimeTile extends StatelessWidget {
  const _MorningTimeTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      (int, int)
    >(
      selector: (s) => (s.morningHour, s.morningMinute),
      builder: (context, hm) => _GlassTimeTile(
        icon: Icons.wb_sunny_rounded,
        iconColor: const Color(0xFFFFC857),
        label: label,
        hour: hm.$1,
        minute: hm.$2,
        onTap: () => _pickTime(
          context,
          slot: ReminderSlotName.morning,
          currentHour: hm.$1,
          currentMinute: hm.$2,
        ),
      ),
    );
  }
}

class _AfternoonTimeTile extends StatelessWidget {
  const _AfternoonTimeTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      (int, int)
    >(
      selector: (s) => (s.afternoonHour, s.afternoonMinute),
      builder: (context, hm) => _GlassTimeTile(
        icon: Icons.wb_cloudy_rounded,
        iconColor: const Color(0xFF8FB8FF),
        label: label,
        hour: hm.$1,
        minute: hm.$2,
        onTap: () => _pickTime(
          context,
          slot: ReminderSlotName.afternoon,
          currentHour: hm.$1,
          currentMinute: hm.$2,
        ),
      ),
    );
  }
}

class _EveningTimeTile extends StatelessWidget {
  const _EveningTimeTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationSettingsBloc,
      NotificationSettingsState,
      (int, int)
    >(
      selector: (s) => (s.eveningHour, s.eveningMinute),
      builder: (context, hm) => _GlassTimeTile(
        icon: Icons.nightlight_round,
        iconColor: const Color(0xFFC9A8FF),
        label: label,
        hour: hm.$1,
        minute: hm.$2,
        onTap: () => _pickTime(
          context,
          slot: ReminderSlotName.evening,
          currentHour: hm.$1,
          currentMinute: hm.$2,
        ),
      ),
    );
  }
}

Future<void> _pickTime(
  BuildContext context, {
  required ReminderSlotName slot,
  required int currentHour,
  required int currentMinute,
}) async {
  // We use showDialog directly (rather than showTimePicker) so we can pass
  // `useSafeArea: false`. showTimePicker hard-codes safe-area on, which is
  // exactly what we want to disable here.
  final picked = await showDialog<TimeOfDay>(
    context: context,
    useSafeArea: false,
    barrierColor: Colors.black54,
    builder: (context) {
      // The picker's own Dialog supplies the bounding rect; we make it
      // transparent and re-skin everything inside with liquid glass plus an
      // accent palette: white for idle/inactive elements, theme primary for
      // selected hour/minute, and redAccent for the cancel button.
      final base = Theme.of(context);
      final primary = context.colors.primary;
      const fg = AppColors.white;
      const cancelFg = Colors.redAccent;
      final glassFill = AppColors.white.withValues(alpha: 0.20);
      final glassBorder = AppColors.white.withValues(alpha: 0.24);

      return Theme(
        data: base.copyWith(
          dialogTheme: base.dialogTheme.copyWith(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            // Zero insets so the dialog goes truly edge-to-edge instead of
            // floating with the default 24/40 margins.
            insetPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(),
          ),
          // Keep `primary` mapped to the actual theme primary so the picker's
          // internal "selected" affordances resolve correctly.
          colorScheme: base.colorScheme.copyWith(
            onSurface: fg,
            primary: primary,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.transparent,
            // Selected hour/minute => primary; unselected => white.
            hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
              // if (states.contains(WidgetState.selected)) return primary;
              return fg;
            }),
            hourMinuteColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return glassFill;
              }
              return Colors.transparent;
            }),
            // Dial: selected numbers get the primary color too.
            dialBackgroundColor: glassFill,
            dialHandColor: primary,
            dialTextColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.white;
              return fg;
            }),
            dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
              // if (states.contains(WidgetState.selected)) return primary;
              return fg;
            }),
            dayPeriodColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return glassFill;
              }
              return Colors.transparent;
            }),
            dayPeriodBorderSide: BorderSide(color: glassBorder),
            entryModeIconColor: fg,
            helpTextStyle: const TextStyle(color: fg),
            hourMinuteTextStyle: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
            ),
            cancelButtonStyle: TextButton.styleFrom(foregroundColor: cancelFg),
            confirmButtonStyle: TextButton.styleFrom(foregroundColor: primary),
          ),
        ),
        child: LiquidGlassLayer(
          fake: false,
          settings: LiquidGlassSettings(lightIntensity: 0),
          child: LiquidGlass.grouped(
            // Borderless corners — full-screen looks weird with rounded ones.
            shape: const LiquidRoundedSuperellipse(borderRadius: 0),
            child: SizedBox.expand(
              child: Center(
                child: TimePickerDialog(
                  initialTime: TimeOfDay(
                    hour: currentHour,
                    minute: currentMinute,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  if (picked == null || !context.mounted) return;
  context.read<NotificationSettingsBloc>().add(
    NotifSlotTimeChanged(slot: slot, hour: picked.hour, minute: picked.minute),
  );
}

// ---------------------------------------------------------------------------
// Reusable glass widgets (presentation only — no bloc state)
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelLarge?.copyWith(
          letterSpacing: 1.2,
          color: AppColors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _GlassToggleTile extends StatelessWidget {
  const _GlassToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return LiquidStretch(
      child: LiquidGlass.grouped(
        shape: LiquidRoundedSuperellipse(borderRadius: 20),
        child: GlassGlow(
          child: SwitchListTile.adaptive(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(20),
            ),
            secondary: Icon(icon, size: 36, color: iconColor),
            title: Text(title, style: context.textTheme.titleLarge),
            subtitle: Text(subtitle, style: context.textTheme.bodyLarge),
            value: value,
            activeTrackColor: context.colors.primary,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _GlassTimeTile extends StatelessWidget {
  const _GlassTimeTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hour,
    required this.minute,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int hour;
  final int minute;
  final VoidCallback onTap;

  String _format(BuildContext context) {
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidStretch(
      child: LiquidGlass.grouped(
        shape: LiquidRoundedSuperellipse(borderRadius: 20),
        child: GlassGlow(
          child: ListTile(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(20),
            ),
            leading: Icon(icon, size: 36, color: iconColor),
            title: Text(label, style: context.textTheme.titleLarge),
            subtitle: Text(
              _format(context),
              style: context.textTheme.bodyLarge,
            ),
            trailing: const Icon(Icons.access_time_rounded),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
