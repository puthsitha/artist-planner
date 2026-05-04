import 'package:flutter/material.dart';

enum GoalPriority {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case GoalPriority.high:
        return 'High';
      case GoalPriority.medium:
        return 'Medium';
      case GoalPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case GoalPriority.high:
        return const Color(0xFFFF6B6B);
      case GoalPriority.medium:
        return const Color(0xFFFFB74D);
      case GoalPriority.low:
        return const Color(0xFF81C784);
    }
  }

  int get weight {
    switch (this) {
      case GoalPriority.high:
        return 3;
      case GoalPriority.medium:
        return 2;
      case GoalPriority.low:
        return 1;
    }
  }
}
