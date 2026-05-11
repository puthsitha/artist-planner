import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class MoodOverview extends StatelessWidget {
  const MoodOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<EmotionBloc, EmotionState>(
      builder: (context, state) {
        final today = DateTime.now();
        final last7 = List.generate(
          7,
          (i) => DateTime(today.year, today.month, today.day - (6 - i)),
        );
        final byDay = state.latestByDay();
        return LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 28),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.normal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mood_this_week,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.avg_score(state.averageScore().toStringAsFixed(1)),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: Spacing.normal),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final d in last7)
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 56,
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                width: 14,
                                height: _heightFor(byDay, d),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xFFFF7A99),
                                      Color(0xFFE7A8FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    Raduis.sm,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.weekdayShort(d.weekday),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double _heightFor(Map<String, EmotionEntry> byDay, DateTime d) {
    final key =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final entry = byDay[key];
    if (entry == null) return 6;
    return 12 + (entry.emotion.score * 9.0); // 21..57
  }
}
