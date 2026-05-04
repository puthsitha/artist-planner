part of 'emotion_bloc.dart';

class EmotionState extends Equatable {
  const EmotionState({this.entries = const []});

  final List<EmotionEntry> entries;

  EmotionState copyWith({List<EmotionEntry>? entries}) {
    return EmotionState(entries: entries ?? this.entries);
  }

  /// Entries logged on a specific day.
  List<EmotionEntry> entriesForDay(DateTime day) {
    return entries.where((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day).toList();
  }

  /// Today's entry for a slot, if any.
  EmotionEntry? entryForSlot(DateTime day, EmotionSlot slot) {
    for (final e in entries) {
      if (e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day &&
          e.slot == slot) {
        return e;
      }
    }
    return null;
  }

  /// Average mood score over the last [days] days. 0 if none logged.
  double averageScore({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = entries.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    final sum = recent.fold<int>(0, (acc, e) => acc + e.emotion.score);
    return sum / recent.length;
  }

  /// Map of dayKey -> dominant emotion (most-recent of the day).
  Map<String, EmotionEntry> latestByDay() {
    final out = <String, EmotionEntry>{};
    for (final e in entries) {
      final key = e.dayKey;
      final existing = out[key];
      if (existing == null || e.date.isAfter(existing.date)) {
        out[key] = e;
      }
    }
    return out;
  }

  @override
  List<Object?> get props => [entries];
}
