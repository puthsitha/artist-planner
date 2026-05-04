part of 'goal_bloc.dart';

class GoalState extends Equatable {
  const GoalState({this.goals = const [], this.reflections = const []});

  final List<MonthlyGoal> goals;
  final List<MonthlyReflection> reflections;

  GoalState copyWith({
    List<MonthlyGoal>? goals,
    List<MonthlyReflection>? reflections,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      reflections: reflections ?? this.reflections,
    );
  }

  /// Goals scoped to a specific month, sorted by priority then created date.
  List<MonthlyGoal> goalsForMonth(int year, int month) {
    final list = goals
        .where((g) => g.year == year && g.month == month)
        .toList()
      ..sort((a, b) {
        final p = b.priority.weight.compareTo(a.priority.weight);
        if (p != 0) return p;
        return (a.createdAt ?? DateTime(1970))
            .compareTo(b.createdAt ?? DateTime(1970));
      });
    return list;
  }

  Map<GoalCategory, List<MonthlyGoal>> goalsByCategory(int year, int month) {
    final out = <GoalCategory, List<MonthlyGoal>>{
      for (final c in GoalCategory.values) c: [],
    };
    for (final g in goalsForMonth(year, month)) {
      out[g.category]!.add(g);
    }
    return out;
  }

  double progressForMonth(int year, int month) {
    final list = goalsForMonth(year, month);
    if (list.isEmpty) return 0;
    final done = list.where((g) => g.isCompleted).length;
    return done / list.length;
  }

  MonthlyReflection? reflectionFor(int year, int month) {
    for (final r in reflections) {
      if (r.year == year && r.month == month) return r;
    }
    return null;
  }

  @override
  List<Object?> get props => [goals, reflections];
}
