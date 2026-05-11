import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
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
        child: ReflectionSheet(year: year, month: month, existing: existing),
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
  bool _isPhraseValid = false;

  @override
  void initState() {
    super.initState();
    _phrase = TextEditingController(text: widget.existing?.phrase ?? '')
      ..addListener(_validatePhrase);
    _note = TextEditingController(text: widget.existing?.note ?? '');
    _reward = TextEditingController(text: widget.existing?.reward ?? '');
    _isPhraseValid = _phrase.text.trim().isNotEmpty;
  }

  void _validatePhrase() {
    setState(() {
      _isPhraseValid = _phrase.text.trim().isNotEmpty;
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                      l10n.reflect_on_month(
                        l10n.monthName(widget.month),
                        widget.year,
                      ),
                      style: context.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        Text(
                          l10n.reflection_in_one_phrase,
                          style: context.textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isPhraseValid)
                          Text(
                            ' (${l10n.required})',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.redPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phrase,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      decoration: _decoration(l10n.reflection_phrase_hint)
                          .copyWith(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Raduis.xl),
                              borderSide: BorderSide(
                                color: !_isPhraseValid
                                    ? AppColors.redPrimary.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.transparent,
                                width: !_isPhraseValid ? 1.5 : 0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Raduis.xl),
                              borderSide: BorderSide(
                                color: !_isPhraseValid
                                    ? AppColors.redPrimary.withValues(
                                        alpha: 0.5,
                                      )
                                    : Colors.transparent,
                                width: !_isPhraseValid ? 1.5 : 0,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      l10n.write_more_optional,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _note,
                      maxLines: 5,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      decoration: _decoration(l10n.write_more_hint),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      l10n.reward_yourself,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reward,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                      decoration: _decoration(l10n.reward_hint),
                    ),
                    const SizedBox(height: Spacing.normal),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPhraseValid ? _save : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: _isPhraseValid
                              ? AppColors.mintPrimary
                              : Colors.grey.withValues(alpha: 0.3),
                          foregroundColor: _isPhraseValid
                              ? Colors.white
                              : Colors.grey.withValues(alpha: 0.6),
                          disabledBackgroundColor: Colors.grey.withValues(
                            alpha: 0.3,
                          ),
                          disabledForegroundColor: Colors.grey.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        child: Text(
                          l10n.save_reflection,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: _isPhraseValid
                                ? Colors.white
                                : Colors.grey.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
      hintStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Raduis.xl),
        borderSide: BorderSide.none,
      ),
    );
  }
}
