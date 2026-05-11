enum EmotionSlot {
  morning,
  afternoon,
  evening;

  String get label {
    switch (this) {
      case EmotionSlot.morning:
        return 'Morning';
      case EmotionSlot.afternoon:
        return 'Afternoon';
      case EmotionSlot.evening:
        return 'Evening';
    }
  }

  String get hint {
    switch (this) {
      case EmotionSlot.morning:
        return 'How are you starting your day?';
      case EmotionSlot.afternoon:
        return 'How is your afternoon going?';
      case EmotionSlot.evening:
        return 'How are you wrapping up your day?';
    }
  }

  /// hour-of-day reminder anchor
  int get reminderHour {
    switch (this) {
      case EmotionSlot.morning:
        return 8;
      case EmotionSlot.afternoon:
        return 14;
      case EmotionSlot.evening:
        return 20;
    }
  }

  static EmotionSlot fromHour(int hour) {
    if (hour < 12) return EmotionSlot.morning;
    if (hour < 18) return EmotionSlot.afternoon;
    return EmotionSlot.evening;
  }
}
