import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/goal/bloc/goal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  });

  final int year;
  final int month;
  final MonthlyGoal? editing;
}

/// Full-screen create/update form for a [MonthlyGoal].
///
/// Replaces the previous bottom-sheet form. Drives navigation through
/// `go_router`'s `context.pop()`. When [editing] is provided the AppBar
/// surfaces a delete action.
class GoalFormPage extends StatefulWidget {
  const GoalFormPage({
    required this.year,
    required this.month,
    this.editing,
    super.key,
  });

  final int year;
  final int month;
  final MonthlyGoal? editing;

  static MaterialPage<void> page({
    required int year,
    required int month,
    MonthlyGoal? editing,
    Key? key,
  }) =>
      MaterialPage<void>(
        child: GoalFormPage(
          year: year,
          month: month,
          editing: editing,
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

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? GoalCategory.personalGrowth;
    _priority = e?.priority ?? GoalPriority.medium;
    _due = e?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final first = DateTime(widget.year, widget.month);
    final last = DateTime(widget.year, widget.month + 1, 0);
    final picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: _due ?? first,
    );
    if (picked != null) setState(() => _due = picked);
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
    final editing = widget.editing;
    if (editing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('"${editing.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    context.read<GoalBloc>().add(GoalDeleted(editing.id));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(isEditing ? 'Edit goal' : 'New goal'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              tooltip: 'Delete goal',
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
                      const _FieldLabel('Title'),
                      TextField(
                        controller: _title,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('What do you want to achieve?'),
                      ),
                      const SizedBox(height: Spacing.sm),
                      const _FieldLabel('Description (optional)'),
                      TextField(
                        controller: _desc,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Add some context…'),
                      ),
                      const SizedBox(height: Spacing.sm),
                      const _FieldLabel('Category'),
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
                      const _FieldLabel('Priority'),
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
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p.label,
                                    style: TextStyle(
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
                      const _FieldLabel('Due date (optional)'),
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
                                    ? 'No due date'
                                    : '${_due!.year}-${_due!.month.toString().padLeft(2, '0')}-${_due!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white),
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
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            isEditing ? 'Save changes' : 'Add goal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: kBottomNavBarHeight + Spacing.l7),
          ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? category.accent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
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
              category.label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
