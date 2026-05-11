import 'package:artistplanner/core/themes/themes.dart';
import 'package:flutter/material.dart';

enum GoalCategory {
  careerEducation,
  personalGrowth,
  finance,
  health,
  selfLove,
  relationship;

  String get label {
    switch (this) {
      case GoalCategory.careerEducation:
        return 'Career / Education';
      case GoalCategory.personalGrowth:
        return 'Personal Growth';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.selfLove:
        return 'Self-Love';
      case GoalCategory.relationship:
        return 'Relationship';
    }
  }

  IconData get icon {
    switch (this) {
      case GoalCategory.careerEducation:
        return Icons.school_rounded;
      case GoalCategory.personalGrowth:
        return Icons.eco_rounded;
      case GoalCategory.finance:
        return Icons.account_balance_wallet_rounded;
      case GoalCategory.health:
        return Icons.favorite_rounded;
      case GoalCategory.selfLove:
        return Icons.spa_rounded;
      case GoalCategory.relationship:
        return Icons.people_alt_rounded;
    }
  }

  Color get accent {
    switch (this) {
      case GoalCategory.careerEducation:
        return const Color(0xFF6FA8FF);
      case GoalCategory.personalGrowth:
        return AppColors.mintPrimary;
      case GoalCategory.finance:
        return const Color(0xFFFFC97A);
      case GoalCategory.health:
        return const Color(0xFFFF7A99);
      case GoalCategory.selfLove:
        return const Color(0xFFE7A8FF);
      case GoalCategory.relationship:
        return const Color(0xFFFFB07A);
    }
  }
}
