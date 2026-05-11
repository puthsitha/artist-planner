import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Arguments passed to [GoalFormPage] via go_router's `extra` field.
///
/// Pass [editing] to open the page in update mode; leave it null to create
/// a brand new goal under [year] / [month].
class GoalFormArgs {
  const GoalFormArgs({
    required this.year,
    required this.month,
    this.editing,
    this.preSelectedCategory,
  });

  final int year;
  final int month;
  final MonthlyGoal? editing;
  final GoalCategory? preSelectedCategory;
}

/// Full-screen create/update form for a [MonthlyGoal].
class GoalFormPage extends StatefulWidget {
  const GoalFormPage({
    required this.year,
    required this.month,
    this.editing,
    this.preSelectedCategory,
    super.key,
  });

  final int year;
  final int month;
  final MonthlyGoal? editing;
  final GoalCategory? preSelectedCategory;

  static MaterialPage<void> page({
    required int year,
    required int month,
    MonthlyGoal? editing,
    GoalCategory? preSelectedCategory,
    Key? key,
  }) => MaterialPage<void>(
    child: GoalFormPage(
      year: year,
      month: month,
      editing: editing,
      preSelectedCategory: preSelectedCategory,
      key: key,
    ),
  );

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late GoalCategory _category;
  late GoalPriority _priority;
  DateTime? _due;
  bool _isTitleValid = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title ?? '')
      ..addListener(_validateTitle);
    _desc = TextEditingController(text: e?.description ?? '');
    _category =
        widget.preSelectedCategory ??
        e?.category ??
        GoalCategory.personalGrowth;
    _priority = e?.priority ?? GoalPriority.medium;
    _due = e?.dueDate;
    _isTitleValid = _title.text.trim().isNotEmpty;
  }

  void _validateTitle() {
    setState(() {
      _isTitleValid = _title.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(widget.year, widget.month + 1, 0);
    final picked = await _showFriendlyDatePicker(
      initialDate: _due ?? first,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<DateTime?> _showFriendlyDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final l10n = context.l10n;
    DateTime selectedDate = initialDate;
    print("lastDate : $lastDate");
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 46,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      l10n.due_date_optional,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _friendlyFormatDate(selectedDate),
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B375F),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              surface: const Color(0xFF2B375F),
                              onSurface: Colors.white,
                              primary: context.colors.primary,
                              onPrimary: Colors.black,
                              onSurfaceVariant: Colors.white,
                            ),
                            textTheme: Theme.of(context).textTheme.apply(
                              bodyColor: Colors.white,
                              displayColor: Colors.white,
                            ),
                          ),
                          child: CalendarDatePicker(
                            initialDate: selectedDate,
                            firstDate: firstDate,
                            lastDate: lastDate,
                            currentDate: DateTime.now(),
                            onDateChanged: (value) =>
                                setState(() => selectedDate = value),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(selectedDate),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary
                                  .withValues(alpha: 0.5),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: context.colors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              l10n.save,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary,
                              ),
                            ),
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
      },
    );
  }

  String _friendlyFormatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMd(locale).format(date);
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final bloc = context.read<GoalBloc>();
    final editing = widget.editing;
    if (editing == null) {
      bloc.add(
        GoalAdded(
          title: title,
          description: _desc.text.trim(),
          category: _category,
          priority: _priority,
          year: widget.year,
          month: widget.month,
          dueDate: _due,
        ),
      );
    } else {
      bloc.add(
        GoalUpdated(
          editing.copyWith(
            title: title,
            description: _desc.text.trim(),
            category: _category,
            priority: _priority,
            dueDate: _due,
            clearDueDate: _due == null,
          ),
        ),
      );
    }
    context.pop();
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final editing = widget.editing;
    if (editing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidGlassLayer(
          fake: false,
          settings: LiquidGlassSettings(lightIntensity: 0),
          child: LiquidGlass.grouped(
            shape: const LiquidRoundedSuperellipse(borderRadius: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.delete_goal_question,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.delete_goal_confirmation(editing.title),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.redPrimary,
                          backgroundColor: AppColors.redPrimary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: Text(l10n.delete_action),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    context.read<GoalBloc>().add(GoalDeleted(editing.id));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.editing != null;
    final fakeGlass = !context.watch<ThemeBloc>().state.isGlassUI;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? l10n.edit_goal : l10n.new_goal,
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: l10n.delete_goal,
              onPressed: _confirmDelete,
            ),
        ],
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
              settings: LiquidGlassSettings(blur: 12, thickness: 28),
              child: LiquidGlass.grouped(
                shape: const LiquidRoundedSuperellipse(borderRadius: 32),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.normal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _FieldLabel(l10n.title_field),
                          if (!_isTitleValid)
                            Text(
                              '(${l10n.required})',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.redPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      TextField(
                        controller: _title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        decoration: _decoration(l10n.title_hint),
                      ),
                      const SizedBox(height: Spacing.sm),
                      _FieldLabel(l10n.description_optional),
                      TextField(
                        controller: _desc,
                        maxLines: 3,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        decoration: _decoration(l10n.description_hint),
                      ),
                      const SizedBox(height: Spacing.sm),
                      _FieldLabel(l10n.category_field),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in GoalCategory.values)
                            _CategoryChip(
                              category: c,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ),
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),
                      _FieldLabel(l10n.priority_field),
                      Row(
                        children: [
                          for (final p in GoalPriority.values) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _priority = p),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _priority == p
                                        ? p.color.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.06),
                                    border: Border.all(
                                      color: _priority == p
                                          ? p.color
                                          : Colors.white24,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Raduis.l,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p.labelOf(l10n),
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: _priority == p
                                              ? p.color
                                              : Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            if (p != GoalPriority.values.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: Spacing.sm),
                      _FieldLabel(l10n.due_date_optional),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDue,
                              icon: const Icon(
                                Icons.event_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                _due == null
                                    ? l10n.no_due_date
                                    : '${_due!.year}-${_due!.month.toString().padLeft(2, '0')}-${_due!.day.toString().padLeft(2, '0')}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(color: Colors.white30),
                              ),
                            ),
                          ),
                          if (_due != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => setState(() => _due = null),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: Spacing.normal),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isTitleValid ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _isTitleValid
                                ? context.colors.primary
                                : Colors.grey.withValues(alpha: 0.3),
                            foregroundColor: _isTitleValid
                                ? Colors.black
                                : Colors.grey.withValues(alpha: 0.6),
                            disabledBackgroundColor: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                            disabledForegroundColor: Colors.grey.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          child: Text(
                            isEditing ? l10n.save_changes : l10n.add_goal,
                            style: context.textTheme.labelLarge?.copyWith(
                              color: _isTitleValid
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
          ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final GoalCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? category.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Raduis.xl),
          border: Border.all(
            color: selected ? category.accent : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 16, color: category.accent),
            const SizedBox(width: 6),
            Text(
              category.labelOf(l10n),
              style: context.textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
