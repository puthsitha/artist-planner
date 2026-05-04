import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class ReflectionSheet extends StatefulWidget {
  const ReflectionSheet({
    required this.year,
    required this.month,
    this.existing,
    super.key,
  });

  final int year;
  final int month;
  final MonthlyReflection? existing;

  static Future<void> show(
    BuildContext context, {
    required int year,
    required int month,
    MonthlyReflection? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalBloc>(),
        child: ReflectionSheet(
          year: year,
          month: month,
          existing: existing,
        ),
      ),
    );
  }

  @override
  State<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<ReflectionSheet> {
  late TextEditingController _phrase;
  late TextEditingController _note;
  late TextEditingController _reward;

  @override
  void initState() {
    super.initState();
    _phrase = TextEditingController(text: widget.existing?.phrase ?? '');
    _note = TextEditingController(text: widget.existing?.note ?? '');
    _reward = TextEditingController(text: widget.existing?.reward ?? '');
  }

  @override
  void dispose() {
    _phrase.dispose();
    _note.dispose();
    _reward.dispose();
    super.dispose();
  }

  void _save() {
    final phrase = _phrase.text.trim();
    if (phrase.isEmpty) return;
    context.read<GoalBloc>().add(
          GoalReflectionSaved(
            year: widget.year,
            month: widget.month,
            phrase: phrase,
            note: _note.text.trim(),
            reward: _reward.text.trim(),
          ),
        );
    Navigator.of(context).pop();
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.normal,
          right: Spacing.normal,
          bottom: bottom + Spacing.normal,
          top: Spacing.normal,
        ),
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(blur: 12, thickness: 28),
          child: LiquidGlass.grouped(
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.normal),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reflect on ${_months[widget.month - 1]} ${widget.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    const Text(
                      'Reflection in one phrase',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phrase,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration(
                        'In one phrase, this month was…',
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    const Text(
                      'Write more (optional)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _note,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration(
                        'Wins, lessons, surprises, gratitudes…',
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    const Text(
                      'Reward yourself',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reward,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration(
                        'A small treat to celebrate yourself…',
                      ),
                    ),
                    const SizedBox(height: Spacing.normal),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save reflection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
