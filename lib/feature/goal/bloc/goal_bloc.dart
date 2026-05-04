import 'dart:developer';

import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends HydratedBloc<GoalEvent, GoalState> {
  GoalBloc() : super(const GoalState()) {
    on<GoalAdded>(_onAdded);
    on<GoalUpdated>(_onUpdated);
    on<GoalDeleted>(_onDeleted);
    on<GoalToggleCompleted>(_onToggle);
    on<GoalReflectionSaved>(_onReflection);
  }

  static const _uuid = Uuid();

  void _onAdded(GoalAdded event, Emitter<GoalState> emit) {
    final goal = MonthlyGoal(
      id: _uuid.v4(),
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
      year: event.year,
      month: event.month,
      dueDate: event.dueDate,
      createdAt: DateTime.now(),
    );
    emit(state.copyWith(goals: [...state.goals, goal]));
  }

  void _onUpdated(GoalUpdated event, Emitter<GoalState> emit) {
    final next = state.goals
        .map((g) => g.id == event.goal.id ? event.goal : g)
        .toList();
    emit(state.copyWith(goals: next));
  }

  void _onDeleted(GoalDeleted event, Emitter<GoalState> emit) {
    final next = state.goals.where((g) => g.id != event.id).toList();
    emit(state.copyWith(goals: next));
  }

  void _onToggle(GoalToggleCompleted event, Emitter<GoalState> emit) {
    final next = state.goals.map((g) {
      if (g.id == event.id) {
        return g.copyWith(isCompleted: !g.isCompleted);
      }
      return g;
    }).toList();
    emit(state.copyWith(goals: next));
  }

  void _onReflection(GoalReflectionSaved event, Emitter<GoalState> emit) {
    final reflection = MonthlyReflection(
      year: event.year,
      month: event.month,
      phrase: event.phrase,
      note: event.note,
      reward: event.reward,
      completedAt: DateTime.now(),
    );
    final others = state.reflections
        .where((r) => !(r.year == event.year && r.month == event.month))
        .toList();
    emit(state.copyWith(reflections: [...others, reflection]));
  }

  @override
  GoalState? fromJson(Map<String, dynamic> json) {
    try {
      final goals = (json['goals'] as List<dynamic>? ?? [])
          .map((e) => MonthlyGoal.fromJson(e as Map<String, dynamic>))
          .toList();
      final refs = (json['reflections'] as List<dynamic>? ?? [])
          .map((e) => MonthlyReflection.fromJson(e as Map<String, dynamic>))
          .toList();
      return GoalState(goals: goals, reflections: refs);
    } on Exception catch (e) {
      log('GoalBloc fromJson error: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(GoalState state) {
    return {
      'goals': state.goals.map((g) => g.toJson()).toList(),
      'reflections': state.reflections.map((r) => r.toJson()).toList(),
    };
  }
}
