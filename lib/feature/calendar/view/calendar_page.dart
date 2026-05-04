import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/feature/dashboard/widgets/emotion_picker_sheet.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
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
    final emotionState = context.watch<EmotionBloc>().state;
    final goalState = context.watch<GoalBloc>().state;
    final byDay = emotionState.latestByDay();
    final goals = goalState.goalsForMonth(_viewMonth.year, _viewMonth.month);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Calendar'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            LiquidGlassLayer(
              fake: false,
              settings: LiquidGlassSettings(),
              child: _MonthHeader(
                month: _viewMonth,
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
            ),
            const SizedBox(height: Spacing.normal),
            LiquidGlassLayer(
              fake: false,
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
              fake: false,
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
            Container(
              color: Colors.red,
              height: kBottomNavBarHeight + Spacing.l,
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.normal,
          vertical: Spacing.s,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_names[month.month - 1]} ${month.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
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
              children: const [
                _DowLabel('Mon'),
                _DowLabel('Tue'),
                _DowLabel('Wed'),
                _DowLabel('Thu'),
                _DowLabel('Fri'),
                _DowLabel('Sat'),
                _DowLabel('Sun'),
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
                          borderRadius: BorderRadius.circular(14),
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (entry != null)
                                    Text(
                                      entry.emotion.emoji,
                                      style: const TextStyle(fontSize: 14),
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
          style: const TextStyle(color: Colors.white60, fontSize: 12),
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
    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDay(day),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            const Text(
              'Emotions logged',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            if (entries.isEmpty)
              const Text(
                'No check-ins yet for this day.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
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
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.slot.label} · ${e.emotion.label}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (e.note.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '— ${e.note}',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
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
            const Text(
              'Goals due',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            if (goals.isEmpty)
              const Text(
                'No goals due on this day.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
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
                              style: const TextStyle(color: Colors.white),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              g.priority.label,
                              style: TextStyle(
                                color: g.priority.color,
                                fontSize: 11,
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
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          EmotionPickerSheet.show(context, date: day, slot: s),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(s.label),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
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

  String _formatDay(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${wd[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
