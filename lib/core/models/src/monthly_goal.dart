import 'package:artistplanner/core/enums/enums.dart';
import 'package:equatable/equatable.dart';

class MonthlyGoal extends Equatable {
  const MonthlyGoal({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.year,
    required this.month,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.createdAt,
  });

  factory MonthlyGoal.fromJson(Map<String, dynamic> json) {
    return MonthlyGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      category: GoalCategory.values.byName(json['category'] as String),
      priority: GoalPriority.values.byName(json['priority'] as String),
      year: json['year'] as int,
      month: json['month'] as int,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final int year;
  final int month;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? createdAt;

  String get monthKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'year': year,
      'month': month,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  MonthlyGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    GoalPriority? priority,
    int? year,
    int? month,
    DateTime? dueDate,
    bool? clearDueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return MonthlyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      year: year ?? this.year,
      month: month ?? this.month,
      dueDate: (clearDueDate ?? false) ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    priority,
    year,
    month,
    dueDate,
    isCompleted,
    createdAt,
  ];
}
