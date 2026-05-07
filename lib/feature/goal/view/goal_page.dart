import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/routes/routes.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/feature/goal/view/goal_form_page.dart';
import 'package:artistplanner/feature/goal/widgets/reflection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: GoalPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const GoalView();
  }
}

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  late DateTime _viewMonth;

  static const _monthNames = [
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
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }

  bool get _monthIsEnding {
    final now = DateTime.now();
    if (_viewMonth.year < now.year ||
        (_viewMonth.year == now.year && _viewMonth.month < now.month)) {
      return true; // past month — definitely ready to reflect
    }
    if (_viewMonth.year == now.year && _viewMonth.month == now.month) {
      final daysInMonth = DateTime(
        _viewMonth.year,
        _viewMonth.month + 1,
        0,
      ).day;
      return now.day >= daysInMonth - 3; // last 3 days
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final fakeGlass = !context.watch<ThemeBloc>().state.isGlassUI;
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        final goalsByCategory = state.goalsByCategory(
          _viewMonth.year,
          _viewMonth.month,
        );
        final allMonth = state.goalsForMonth(_viewMonth.year, _viewMonth.month);
        final reflection = state.reflectionFor(
          _viewMonth.year,
          _viewMonth.month,
        );
        final progress = state.progressForMonth(
          _viewMonth.year,
          _viewMonth.month,
        );

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Goals'),
          ),
          floatingActionButton: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: kBottomNavBarHeight + Spacing.l7,
              ),
              child: FloatingActionButton.extended(
                foregroundColor: Colors.white,
                onPressed: () => context.pushNamed(
                  Pages.goalForm.name,
                  extra: GoalFormArgs(
                    year: _viewMonth.year,
                    month: _viewMonth.month,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('New goal'),
              ),
            ),
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
                  child: _MonthSwitcher(
                    label:
                        '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                    onPrev: () => _shiftMonth(-1),
                    onNext: () => _shiftMonth(1),
                  ),
                ),
                const SizedBox(height: Spacing.normal),
                LiquidGlassLayer(
                  fake: fakeGlass,
                  settings: LiquidGlassSettings(),
                  child: _ProgressCard(
                    progress: progress,
                    total: allMonth.length,
                    done: allMonth.where((g) => g.isCompleted).length,
                  ),
                ),
                if (_monthIsEnding) ...[
                  const SizedBox(height: Spacing.normal),
                  LiquidGlassLayer(
                    fake: fakeGlass,
                    settings: LiquidGlassSettings(),
                    child: _ReflectionCard(
                      year: _viewMonth.year,
                      month: _viewMonth.month,
                      reflection: reflection,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.l),
                for (final cat in GoalCategory.values)
                  LiquidGlassLayer(
                    fake: fakeGlass,
                    settings: LiquidGlassSettings(),
                    child: _CategorySection(
                      category: cat,
                      goals: goalsByCategory[cat] ?? const [],
                      onAdd: () => context.pushNamed(
                        Pages.goalForm.name,
                        extra: GoalFormArgs(
                          year: _viewMonth.year,
                          month: _viewMonth.month,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: kBottomNavBarHeight + Spacing.l10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

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
                  label,
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.total,
    required this.done,
  });

  final double progress;
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Monthly progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$done / $total',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7FE5B6),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              total == 0
                  ? 'No goals for this month yet.'
                  : '${(progress * 100).round()}% complete',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.year,
    required this.month,
    required this.reflection,
  });

  final int year;
  final int month;
  final MonthlyReflection? reflection;

  @override
  Widget build(BuildContext context) {
    final hasReflection = reflection != null && reflection!.isComplete;
    return LiquidGlass.grouped(
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFE7A8FF)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'End-of-month reflection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => ReflectionSheet.show(
                    context,
                    year: year,
                    month: month,
                    existing: reflection,
                  ),
                  child: Text(hasReflection ? 'Edit' : 'Reflect'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            if (!hasReflection)
              const Text(
                'The month is wrapping up. Take a moment to reflect — '
                'one phrase, optional notes, and a reward for yourself.',
                style: TextStyle(color: Colors.white70),
              )
            else ...[
              Text(
                '"${reflection!.phrase}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (reflection!.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reflection!.note,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              if (reflection!.reward.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_outlined,
                      color: Color(0xFFFFC97A),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reward: ${reflection!.reward}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.goals,
    required this.onAdd,
  });

  final GoalCategory category;
  final List<MonthlyGoal> goals;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.normal),
      child: LiquidGlass.grouped(
        shape: const LiquidRoundedSuperellipse(borderRadius: 28),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.normal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, color: category.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${goals.where((g) => g.isCompleted).length}/${goals.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              if (goals.isEmpty)
                _EmptyHint(category: category, onAdd: onAdd)
              else
                Column(children: [for (final g in goals) _GoalTile(goal: g)]),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.category, required this.onAdd});

  final GoalCategory category;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 16, color: Colors.white60),
            const SizedBox(width: 8),
            Text(
              'Add a ${category.label.toLowerCase()} goal',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal});

  final MonthlyGoal goal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.pushNamed(
          Pages.goalForm.name,
          extra: GoalFormArgs(
            year: goal.year,
            month: goal.month,
            editing: goal,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.read<GoalBloc>().add(GoalToggleCompleted(goal.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goal.isCompleted
                          ? const Color(0xFF7FE5B6)
                          : Colors.white54,
                      width: 1.5,
                    ),
                    color: goal.isCompleted
                        ? const Color(0xFF7FE5B6).withValues(alpha: 0.7)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: goal.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white54,
                      ),
                    ),
                    if (goal.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Due ${goal.dueDate!.year}-${goal.dueDate!.month.toString().padLeft(2, '0')}-${goal.dueDate!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: goal.priority.color.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.priority.label,
                  style: TextStyle(
                    color: goal.priority.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    context.read<GoalBloc>().add(GoalDeleted(goal.id)),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
