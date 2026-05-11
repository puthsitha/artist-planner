part of 'goal_bloc.dart';

sealed class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class GoalAdded extends GoalEvent {
  const GoalAdded({
    required this.title,
    required this.category,
    required this.priority,
    required this.year,
    required this.month,
    this.description = '',
    this.dueDate,
  });

  final String title;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final int year;
  final int month;
  final DateTime? dueDate;

  @override
  List<Object?> get props =>
      [title, description, category, priority, year, month, dueDate];
}

class GoalUpdated extends GoalEvent {
  const GoalUpdated(this.goal);

  final MonthlyGoal goal;

  @override
  List<Object?> get props => [goal];
}

class GoalDeleted extends GoalEvent {
  const GoalDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class GoalToggleCompleted extends GoalEvent {
  const GoalToggleCompleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class GoalReflectionSaved extends GoalEvent {
  const GoalReflectionSaved({
    required this.year,
    required this.month,
    required this.phrase,
    this.note = '',
    this.reward = '',
  });

  final int year;
  final int month;
  final String phrase;
  final String note;
  final String reward;

  @override
  List<Object?> get props => [year, month, phrase, note, reward];
}
