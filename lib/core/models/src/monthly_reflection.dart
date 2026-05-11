import 'package:equatable/equatable.dart';

class MonthlyReflection extends Equatable {
  const MonthlyReflection({
    required this.year,
    required this.month,
    this.phrase = '',
    this.note = '',
    this.reward = '',
    this.completedAt,
  });

  factory MonthlyReflection.fromJson(Map<String, dynamic> json) {
    return MonthlyReflection(
      year: json['year'] as int,
      month: json['month'] as int,
      phrase: (json['phrase'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      reward: (json['reward'] as String?) ?? '',
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }

  final int year;
  final int month;
  final String phrase;
  final String note;
  final String reward;
  final DateTime? completedAt;

  String get monthKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  bool get isComplete => phrase.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'phrase': phrase,
      'note': note,
      'reward': reward,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  MonthlyReflection copyWith({
    int? year,
    int? month,
    String? phrase,
    String? note,
    String? reward,
    DateTime? completedAt,
  }) {
    return MonthlyReflection(
      year: year ?? this.year,
      month: month ?? this.month,
      phrase: phrase ?? this.phrase,
      note: note ?? this.note,
      reward: reward ?? this.reward,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [year, month, phrase, note, reward, completedAt];
}
