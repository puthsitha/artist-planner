import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/feature/dashboard/widgets/emotion_picker_sheet.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:artistplanner/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: CalendarPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const CalendarView();
  }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _viewMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final emotionState = context.watch<EmotionBloc>().state;
    final goalState = context.watch<GoalBloc>().state;
    final byDay = emotionState.latestByDay();
    final goals = goalState.goalsForMonth(_viewMonth.year, _viewMonth.month);
    final fakeGlass = !context.watch<ThemeBloc>().state.isGlassUI;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.calendar_title),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: Spacing.normal,
            left: Spacing.normal,
            right: Spacing.normal,
          ),
          children: [
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: MonthSelector(
                month: _viewMonth,
                onMonthChanged: (newMonth) =>
                    setState(() => _viewMonth = newMonth),
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
            ),
            const SizedBox(height: Spacing.normal),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: _CalendarGrid(
                month: _viewMonth,
                selected: _selected,
                entriesByDay: byDay,
                goals: goals,
                onSelect: (d) => setState(() => _selected = d),
              ),
            ),
            const SizedBox(height: Spacing.l),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: _DaySummary(
                day: _selected,
                entries: emotionState.entriesForDay(_selected),
                goals: goals
                    .where(
                      (g) =>
                          g.dueDate != null &&
                          _isSameDay(g.dueDate!, _selected),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: kBottomNavBarHeight + Spacing.l7),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selected,
    required this.entriesByDay,
    required this.goals,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Map<String, EmotionEntry> entriesByDay;
  final List<MonthlyGoal> goals;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = (firstDay.weekday - 1) % 7;
    final cells = leadingBlanks + daysInMonth;
    final rows = (cells / 7).ceil();
    final today = DateTime.now();

    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.normal),
        child: Column(
          children: [
            Row(
              children: [
                _DowLabel(l10n.weekday_short_mon),
                _DowLabel(l10n.weekday_short_tue),
                _DowLabel(l10n.weekday_short_wed),
                _DowLabel(l10n.weekday_short_thu),
                _DowLabel(l10n.weekday_short_fri),
                _DowLabel(l10n.weekday_short_sat),
                _DowLabel(l10n.weekday_short_sun),
              ],
            ),
            const SizedBox(height: 8),
            for (var r = 0; r < rows; r++)
              Row(
                children: List.generate(7, (c) {
                  final i = r * 7 + c;
                  final dayNumber = i - leadingBlanks + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 56));
                  }
                  final day = DateTime(month.year, month.month, dayNumber);
                  final entry = entriesByDay[_keyFor(day)];
                  final hasGoal = goals.any(
                    (g) =>
                        g.dueDate != null &&
                        g.dueDate!.year == day.year &&
                        g.dueDate!.month == day.month &&
                        g.dueDate!.day == day.day,
                  );
                  final isToday = _sameDay(day, today);
                  final isSelected = _sameDay(day, selected);
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(day),
                      child: Container(
                        height: 56,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.22)
                              : isToday
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(Raduis.l),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 1.2)
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayNumber',
                                    style: context.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: isToday
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                  ),
                                  if (entry != null)
                                    Text(
                                      entry.emotion.emoji,
                                      style: context.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            if (hasGoal)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFB07A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  static String _keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DowLabel extends StatelessWidget {
  const _DowLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({
    required this.day,
    required this.entries,
    required this.goals,
  });

  final DateTime day;
  final List<EmotionEntry> entries;
  final List<MonthlyGoal> goals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Latest entry per slot for this day — used to render check vs +
    final latestPerSlot = <EmotionSlot, EmotionEntry>{};
    for (final e in entries) {
      final existing = latestPerSlot[e.slot];
      if (existing == null || e.date.isAfter(existing.date)) {
        latestPerSlot[e.slot] = e;
      }
    }

    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDay(day, l10n),
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.emotions_logged,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            if (entries.isEmpty)
              Text(
                l10n.no_check_ins_for_day,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              )
            else
              Column(
                children: [
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            e.emotion.emoji,
                            style: context.textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.slot.labelOf(l10n)} · ${e.emotion.labelOf(l10n)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          if (e.note.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '— ${e.note}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: Spacing.sm),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.goals_due,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            if (goals.isEmpty)
              Text(
                l10n.no_goals_due_for_day,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              )
            else
              Column(
                children: [
                  for (final g in goals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            g.category.icon,
                            size: 18,
                            color: g.category.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              g.title,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: g.priority.color.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(Raduis.sm),
                            ),
                            child: Text(
                              g.priority.labelOf(l10n),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: g.priority.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: Spacing.normal),
            Row(
              children: [
                for (final s in EmotionSlot.values) ...[
                  Expanded(
                    child: _SlotCheckInButton(
                      slot: s,
                      entry: latestPerSlot[s],
                      onTap: () =>
                          EmotionPickerSheet.show(context, date: day, slot: s),
                    ),
                  ),
                  if (s != EmotionSlot.values.last) const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDay(DateTime d, AppLocalizations l10n) {
    return '${l10n.weekdayShort(d.weekday)}, ${l10n.monthShort(d.month)} ${d.day}, ${d.year}';
  }
}

/// Per-slot check-in button used inside [_DaySummary].
class _SlotCheckInButton extends StatelessWidget {
  const _SlotCheckInButton({
    required this.slot,
    required this.entry,
    required this.onTap,
  });

  final EmotionSlot slot;
  final EmotionEntry? entry;
  final VoidCallback onTap;

  static const _accent = Color(0xFFFFB7C5); // soft pink to match theme

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logged = entry != null;

    if (!logged) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 16),
        label: Text(slot.labelOf(l10n), style: context.textTheme.labelSmall),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white30),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _accent.withValues(alpha: 0.18),
        side: BorderSide(color: _accent.withValues(alpha: 0.7)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: _accent),
          const SizedBox(width: 4),
          Text(entry!.emotion.emoji, style: context.textTheme.bodySmall),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              slot.labelOf(l10n),
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
