import 'package:artistplanner/core/enums/enums.dart';
import 'package:equatable/equatable.dart';

class EmotionEntry extends Equatable {
  const EmotionEntry({
    required this.id,
    required this.date,
    required this.slot,
    required this.emotion,
    this.note = '',
  });

  factory EmotionEntry.fromJson(Map<String, dynamic> json) {
    return EmotionEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      slot: EmotionSlot.values.byName(json['slot'] as String),
      emotion: EmotionType.values.byName(json['emotion'] as String),
      note: (json['note'] as String?) ?? '',
    );
  }

  final String id;
  final DateTime date;
  final EmotionSlot slot;
  final EmotionType emotion;
  final String note;

  /// Day-only key (YYYY-MM-DD) used to group entries by date.
  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'slot': slot.name,
      'emotion': emotion.name,
      'note': note,
    };
  }

  EmotionEntry copyWith({
    String? id,
    DateTime? date,
    EmotionSlot? slot,
    EmotionType? emotion,
    String? note,
  }) {
    return EmotionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      emotion: emotion ?? this.emotion,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, date, slot, emotion, note];
}
