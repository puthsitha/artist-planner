import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/dashboard/bloc/emotion_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class EmotionPickerSheet extends StatefulWidget {
  const EmotionPickerSheet({required this.date, required this.slot, super.key});

  final DateTime date;
  final EmotionSlot slot;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required EmotionSlot slot,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<EmotionBloc>(),
        child: EmotionPickerSheet(date: date, slot: slot),
      ),
    );
  }

  @override
  State<EmotionPickerSheet> createState() => _EmotionPickerSheetState();
}

class _EmotionPickerSheetState extends State<EmotionPickerSheet> {
  EmotionType? _selected;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final existing = context.read<EmotionBloc>().state.entryForSlot(
      widget.date,
      widget.slot,
    );
    _selected = existing?.emotion;
    _noteController = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final selection = _selected;
    if (selection == null) return;
    context.read<EmotionBloc>().add(
      EmotionLogged(
        date: widget.date,
        slot: widget.slot,
        emotion: selection,
        note: _noteController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.normal,
          right: Spacing.normal,
          bottom: bottomInset + Spacing.normal,
          top: Spacing.normal,
        ),
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(blur: 12, thickness: 28),
          child: LiquidGlass.grouped(
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.normal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.slot == EmotionSlot.morning
                            ? Icons.wb_sunny_outlined
                            : widget.slot == EmotionSlot.afternoon
                            ? Icons.wb_cloudy_outlined
                            : Icons.nightlight_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        l10n.slot_check_in_title(widget.slot.labelOf(l10n)),
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    widget.slot.hintOf(l10n),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: Spacing.normal),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final e in EmotionType.values)
                        _EmotionChip(
                          emotion: e,
                          selected: _selected == e,
                          onTap: () => setState(() => _selected = e),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.normal),
                  TextField(
                    controller: _noteController,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.optional_emotion_note_hint,
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Raduis.xl),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.normal),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selected == null ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _selected != null
                            ? context.colors.primary
                            : Colors.grey.withValues(alpha: 0.3),
                        foregroundColor: _selected != null
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
                        l10n.save_check_in,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: _selected != null
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
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.emotion,
    required this.selected,
    required this.onTap,
  });

  final EmotionType emotion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Raduis.xl),
          border: Border.all(
            color: selected ? context.colors.primary : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emotion.emoji, style: context.textTheme.headlineSmall),
            const SizedBox(width: 6),
            Text(
              emotion.labelOf(l10n),
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
