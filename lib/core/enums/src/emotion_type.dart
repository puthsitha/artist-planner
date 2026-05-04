enum EmotionType {
  joyful,
  grateful,
  calm,
  motivated,
  tired,
  anxious,
  sad,
  angry;

  String get label {
    switch (this) {
      case EmotionType.joyful:
        return 'Joyful';
      case EmotionType.grateful:
        return 'Grateful';
      case EmotionType.calm:
        return 'Calm';
      case EmotionType.motivated:
        return 'Motivated';
      case EmotionType.tired:
        return 'Tired';
      case EmotionType.anxious:
        return 'Anxious';
      case EmotionType.sad:
        return 'Sad';
      case EmotionType.angry:
        return 'Angry';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionType.joyful:
        return '😊';
      case EmotionType.grateful:
        return '🙏';
      case EmotionType.calm:
        return '😌';
      case EmotionType.motivated:
        return '🔥';
      case EmotionType.tired:
        return '😴';
      case EmotionType.anxious:
        return '😟';
      case EmotionType.sad:
        return '😔';
      case EmotionType.angry:
        return '😠';
    }
  }

  /// 1 = very negative, 5 = very positive. Used for analytics chart.
  int get score {
    switch (this) {
      case EmotionType.joyful:
        return 5;
      case EmotionType.grateful:
        return 5;
      case EmotionType.motivated:
        return 4;
      case EmotionType.calm:
        return 4;
      case EmotionType.tired:
        return 3;
      case EmotionType.anxious:
        return 2;
      case EmotionType.sad:
        return 2;
      case EmotionType.angry:
        return 1;
    }
  }
}
