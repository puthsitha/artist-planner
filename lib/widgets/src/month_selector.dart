import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// A reusable widget for displaying and selecting a month/year.
///
/// This widget provides month navigation with previous/next buttons,
/// and allows tapping on the month display to open a date picker.
///
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    required this.month,
    required this.onMonthChanged,
    this.onPrev,
    this.onNext,
    this.showGlassEffect = true,
    super.key,
  });

  /// The currently selected month
  final DateTime month;

  /// Callback when month is changed (either by buttons or picker)
  final ValueChanged<DateTime> onMonthChanged;

  /// Optional callback for previous month button
  final VoidCallback? onPrev;

  /// Optional callback for next month button
  final VoidCallback? onNext;

  /// Whether to apply glass morphism effect
  final bool showGlassEffect;

  void _handlePrev(BuildContext context) {
    if (onPrev != null) {
      onPrev!();
    } else {
      onMonthChanged(DateTime(month.year, month.month - 1));
    }
  }

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      onMonthChanged(DateTime(month.year, month.month + 1));
    }
  }

  void _handleMonthTap(BuildContext context) {
    _showMonthYearPicker(context);
  }

  void _showMonthYearPicker(BuildContext context) {
    showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = month.year;
        int selectedMonth = month.month;

        // Calculate initial indices
        final yearIndex = month.year - (DateTime.now().year - 5);
        final monthIndex = month.month - 1;

        // Create scroll controllers
        final yearScrollController = FixedExtentScrollController(
          initialItem: yearIndex.clamp(0, 10),
        );
        final monthScrollController = FixedExtentScrollController(
          initialItem: monthIndex.clamp(0, 11),
        );

        return AlertDialog(
          title: Text(context.l10n.select_month_year),
          backgroundColor: const Color(0xFF2A2A3E),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year Selector
                Text(
                  context.l10n.select_year,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.s),
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      // Background highlight for selected year
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.mintPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.mintPrimary.withValues(
                                alpha: 0.5,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Year wheel scroll view
                      ListWheelScrollView(
                        controller: yearScrollController,
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          selectedYear = DateTime.now().year - 5 + index;
                        },
                        children: List.generate(11, (index) {
                          final year = DateTime.now().year - 5 + index;
                          return Center(
                            child: Text(
                              year.toString(),
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: year == month.year
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: year == selectedYear
                                    ? AppColors.mintPrimary
                                    : Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.normal),
                // Month Selector
                Text(
                  context.l10n.select_month,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.s),
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      // Background highlight for selected month
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.mintPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.mintPrimary.withValues(
                                alpha: 0.5,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Month wheel scroll view
                      ListWheelScrollView(
                        controller: monthScrollController,
                        itemExtent: 40,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          selectedMonth = index + 1;
                        },
                        children: List.generate(12, (index) {
                          final monthNum = index + 1;
                          return Center(
                            child: Text(
                              context.l10n.monthName(monthNum),
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: monthNum == month.month
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: monthNum == selectedMonth
                                    ? AppColors.mintPrimary
                                    : Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.redPrimary,
                side: BorderSide(
                  color: AppColors.redPrimary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                overlayColor: AppColors.redPrimary.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.normal,
                  vertical: Spacing.s,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                yearScrollController.dispose();
                monthScrollController.dispose();
              },
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.mintPrimary.withValues(alpha: 0.2),
                foregroundColor: AppColors.mintPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.normal,
                  vertical: Spacing.s,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onMonthChanged(DateTime(selectedYear, selectedMonth));
                yearScrollController.dispose();
                monthScrollController.dispose();
              },
              child: Text(context.l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
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
              onPressed: () => _handlePrev(context),
              icon: const Icon(Icons.chevron_left, color: Colors.white),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _handleMonthTap(context),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.xs,
                    children: [
                      Text(
                        '${l10n.monthName(month.month)} ${month.year}',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        context.l10n.tap_to_select,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _handleNext(context),
              icon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showGlassEffect) {
      return _buildContent(context);
    } else {
      // Return without glass effect wrapper if not needed
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey.withValues(alpha: 0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.normal,
            vertical: Spacing.s,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _handlePrev(context),
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleMonthTap(context),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${context.l10n.monthName(month.month)} ${month.year}',
                          style: context.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          context.l10n.tap_to_select,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _handleNext(context),
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }
}
