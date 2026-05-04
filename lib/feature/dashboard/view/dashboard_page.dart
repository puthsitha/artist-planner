import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/feature/dashboard/widgets/emotion_picker_sheet.dart';
import 'package:artistplanner/feature/dashboard/widgets/mood_overview.dart';
import 'package:artistplanner/feature/dashboard/widgets/quote_banner.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ✨';
    if (h < 18) return 'Good afternoon 🌿';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: LiquidGlassLayer(
          fake: false,
          settings: LiquidGlassSettings(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.normal,
              Spacing.normal,
              Spacing.normal,
              kBottomNavBarHeight + Spacing.l,
            ),
            children: [
              Text(
                _greeting(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Plant a small kindness in your day, artist.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: Spacing.normal),
              const QuoteBanner(),
              const SizedBox(height: Spacing.l),
              _DailyCheckInRow(today: today),
              const SizedBox(height: Spacing.l),
              const MoodOverview(),
              const SizedBox(height: Spacing.l),
              _MonthlyProgressCard(year: today.year, month: today.month),
            ],
          ),
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
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's emotion check-ins",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
    final hasEntry = entry != null;
    return GestureDetector(
      onTap: onTap,
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
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(
                slot.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasEntry ? entry!.emotion.label : 'Tap to log',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
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
                    const Expanded(
                      child: Text(
                        "This month's goals",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$completed/${goals.length}',
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
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE7A8FF),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  goals.isEmpty
                      ? 'No goals yet — add some on the Goal tab.'
                      : '${(progress * 100).round()}% complete',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
