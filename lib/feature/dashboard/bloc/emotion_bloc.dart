import 'dart:developer';

import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';

part 'emotion_event.dart';
part 'emotion_state.dart';

class EmotionBloc extends HydratedBloc<EmotionEvent, EmotionState> {
  EmotionBloc() : super(const EmotionState()) {
    on<EmotionLogged>(_onLogged);
    on<EmotionDeleted>(_onDeleted);
  }

  static const _uuid = Uuid();

  void _onLogged(EmotionLogged event, Emitter<EmotionState> emit) {
    final dayKey = _dayKey(event.date);
    final next = List<EmotionEntry>.from(state.entries)
      // remove any prior entry for the same date+slot
      ..removeWhere(
        (e) => _dayKey(e.date) == dayKey && e.slot == event.slot,
      )
      ..add(
        EmotionEntry(
          id: _uuid.v4(),
          date: event.date,
          slot: event.slot,
          emotion: event.emotion,
          note: event.note,
        ),
      )
      ..sort((a, b) => b.date.compareTo(a.date));
    emit(state.copyWith(entries: next));
  }

  void _onDeleted(EmotionDeleted event, Emitter<EmotionState> emit) {
    final next = List<EmotionEntry>.from(state.entries)
      ..removeWhere((e) => e.id == event.id);
    emit(state.copyWith(entries: next));
  }

  static String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  EmotionState? fromJson(Map<String, dynamic> json) {
    try {
      final raw = (json['entries'] as List<dynamic>? ?? [])
          .map((e) => EmotionEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return EmotionState(entries: raw);
    } on Exception catch (e) {
      log('EmotionBloc fromJson error: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(EmotionState state) {
    return {
      'entries': state.entries.map((e) => e.toJson()).toList(),
    };
  }
}
