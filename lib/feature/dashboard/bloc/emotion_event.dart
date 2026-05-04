part of 'emotion_bloc.dart';

sealed class EmotionEvent extends Equatable {
  const EmotionEvent();

  @override
  List<Object?> get props => [];
}

class EmotionLogged extends EmotionEvent {
  const EmotionLogged({
    required this.date,
    required this.slot,
    required this.emotion,
    this.note = '',
  });

  final DateTime date;
  final EmotionSlot slot;
  final EmotionType emotion;
  final String note;

  @override
  List<Object?> get props => [date, slot, emotion, note];
}

class EmotionDeleted extends EmotionEvent {
  const EmotionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
