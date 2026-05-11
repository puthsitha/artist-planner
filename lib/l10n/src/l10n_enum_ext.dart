import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/l10n/gen/app_localizations.dart';

/// Localized helpers for the enums used across the app.
///
/// Each enum keeps its non-localized `label` getter (and other helpers like
/// `icon`, `color`, `score`) for places where context isn't available; the
/// extensions below provide a translated label / hint that should be used in
/// every UI surface.
extension EmotionTypeL10n on EmotionType {
  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case EmotionType.joyful:
        return l10n.emotion_joyful;
      case EmotionType.grateful:
        return l10n.emotion_grateful;
      case EmotionType.calm:
        return l10n.emotion_calm;
      case EmotionType.motivated:
        return l10n.emotion_motivated;
      case EmotionType.tired:
        return l10n.emotion_tired;
      case EmotionType.anxious:
        return l10n.emotion_anxious;
      case EmotionType.sad:
        return l10n.emotion_sad;
      case EmotionType.angry:
        return l10n.emotion_angry;
    }
  }
}

extension EmotionSlotL10n on EmotionSlot {
  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case EmotionSlot.morning:
        return l10n.slot_morning;
      case EmotionSlot.afternoon:
        return l10n.slot_afternoon;
      case EmotionSlot.evening:
        return l10n.slot_evening;
    }
  }

  String hintOf(AppLocalizations l10n) {
    switch (this) {
      case EmotionSlot.morning:
        return l10n.slot_morning_hint;
      case EmotionSlot.afternoon:
        return l10n.slot_afternoon_hint;
      case EmotionSlot.evening:
        return l10n.slot_evening_hint;
    }
  }
}

extension GoalCategoryL10n on GoalCategory {
  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case GoalCategory.careerEducation:
        return l10n.category_career_education;
      case GoalCategory.personalGrowth:
        return l10n.category_personal_growth;
      case GoalCategory.finance:
        return l10n.category_finance;
      case GoalCategory.health:
        return l10n.category_health;
      case GoalCategory.selfLove:
        return l10n.category_self_love;
      case GoalCategory.relationship:
        return l10n.category_relationship;
    }
  }
}

extension GoalPriorityL10n on GoalPriority {
  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case GoalPriority.high:
        return l10n.priority_high;
      case GoalPriority.medium:
        return l10n.priority_medium;
      case GoalPriority.low:
        return l10n.priority_low;
    }
  }
}

extension ThemeColorL10n on ThemeColor {
  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case ThemeColor.defaultTheme:
        return l10n.theme_midnight_black;
      case ThemeColor.brownTheme:
        return l10n.theme_warm_brown;
      case ThemeColor.pinkTheme:
        return l10n.theme_soft_pink;
    }
  }
}

/// Helpers for resolving date pieces (months, weekdays) from raw integers,
/// since the app builds month/year strings manually in several places instead
/// of going through `intl.DateFormat`.
extension DateL10n on AppLocalizations {
  /// Full month name. [month] is 1-based (January = 1).
  String monthName(int month) {
    switch (month) {
      case 1:
        return month_january;
      case 2:
        return month_february;
      case 3:
        return month_march;
      case 4:
        return month_april;
      case 5:
        return month_may;
      case 6:
        return month_june;
      case 7:
        return month_july;
      case 8:
        return month_august;
      case 9:
        return month_september;
      case 10:
        return month_october;
      case 11:
        return month_november;
      case 12:
        return month_december;
      default:
        return '';
    }
  }

  /// Short month label (Jan, Feb, …). [month] is 1-based.
  String monthShort(int month) {
    switch (month) {
      case 1:
        return month_short_jan;
      case 2:
        return month_short_feb;
      case 3:
        return month_short_mar;
      case 4:
        return month_short_apr;
      case 5:
        return month_short_may;
      case 6:
        return month_short_jun;
      case 7:
        return month_short_jul;
      case 8:
        return month_short_aug;
      case 9:
        return month_short_sep;
      case 10:
        return month_short_oct;
      case 11:
        return month_short_nov;
      case 12:
        return month_short_dec;
      default:
        return '';
    }
  }

  /// Short weekday label (Mon, Tue, …). [weekday] follows
  /// [DateTime.weekday] (Monday = 1, Sunday = 7).
  String weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return weekday_short_mon;
      case DateTime.tuesday:
        return weekday_short_tue;
      case DateTime.wednesday:
        return weekday_short_wed;
      case DateTime.thursday:
        return weekday_short_thu;
      case DateTime.friday:
        return weekday_short_fri;
      case DateTime.saturday:
        return weekday_short_sat;
      case DateTime.sunday:
        return weekday_short_sun;
      default:
        return '';
    }
  }
}
