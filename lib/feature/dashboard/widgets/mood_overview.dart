import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class MoodOverview extends StatelessWidget {
  const MoodOverview({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Mood this week',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Avg score: ${state.averageScore().toStringAsFixed(1)} / 5',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _weekday(d),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
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

  static String _weekday(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[d.weekday - 1];
  }
}
