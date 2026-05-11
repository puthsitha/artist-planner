import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/feature/dashboard/widgets/emotion_picker_sheet.dart';
import 'package:artistplanner/feature/dashboard/widgets/mood_overview.dart';
import 'package:artistplanner/feature/dashboard/widgets/quote_banner.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: DashboardPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.good_morning;
    if (h < 18) return l10n.good_afternoon;
    return l10n.good_evening;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final l10n = context.l10n;
    final fakeGlass = !context.watch<ThemeBloc>().state.isGlassUI;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: Spacing.normal,
            left: Spacing.normal,
            right: Spacing.normal,
          ),
          children: [
            Text(
              _greeting(l10n),
              style: context.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.dashboard_kindness_subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: Spacing.normal),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: const QuoteBanner(),
            ),
            const SizedBox(height: Spacing.l),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: _DailyCheckInRow(today: today),
            ),
            const SizedBox(height: Spacing.l),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: const MoodOverview(),
            ),
            const SizedBox(height: Spacing.l),
            LiquidGlassLayer(
              fake: fakeGlass,
              settings: LiquidGlassSettings(),
              child: _MonthlyProgressCard(year: today.year, month: today.month),
            ),
            SizedBox(height: kBottomNavBarHeight + Spacing.l7),
          ],
        ),
      ),
    );
  }
}

class _DailyCheckInRow extends StatelessWidget {
  const _DailyCheckInRow({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todays_emotion_check_ins,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                for (final slot in EmotionSlot.values) ...[
                  Expanded(
                    child: _SlotTile(
                      slot: slot,
                      entry: state.entryForSlot(today, slot),
                      onTap: () => EmotionPickerSheet.show(
                        context,
                        date: today,
                        slot: slot,
                      ),
                    ),
                  ),
                  if (slot != EmotionSlot.values.last)
                    const SizedBox(width: Spacing.sm),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.entry,
    required this.onTap,
  });

  final EmotionSlot slot;
  final EmotionEntry? entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasEntry = entry != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: LiquidGlass.grouped(
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
        child: Container(
          padding: const EdgeInsets.all(Spacing.m),
          height: 110,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hasEntry ? entry!.emotion.emoji : '＋',
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                slot.labelOf(l10n),
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasEntry ? entry!.emotion.labelOf(l10n) : l10n.tap_to_log,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white60,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyProgressCard extends StatelessWidget {
  const _MonthlyProgressCard({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        final progress = state.progressForMonth(year, month);
        final goals = state.goalsForMonth(year, month);
        final completed = goals.where((g) => g.isCompleted).length;
        return LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 28),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.normal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.this_months_goals,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$completed/${goals.length}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Raduis.normal),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  goals.isEmpty
                      ? l10n.no_goals_yet_dashboard
                      : l10n.percent_complete((progress * 100).round()),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
