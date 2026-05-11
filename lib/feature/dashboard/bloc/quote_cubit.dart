import 'dart:math';

import 'package:artistplanner/core/models/models.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class QuoteState extends Equatable {
  const QuoteState({required this.quotes, required this.activeIndex});

  factory QuoteState.initial() {
    final pool = List<Quote>.from(kInspirationalQuotes)..shuffle(Random());
    return QuoteState(quotes: pool, activeIndex: 0);
  }

  final List<Quote> quotes;
  final int activeIndex;

  Quote get current => quotes[activeIndex];

  QuoteState copyWith({List<Quote>? quotes, int? activeIndex}) {
    return QuoteState(
      quotes: quotes ?? this.quotes,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }

  @override
  List<Object?> get props => [quotes, activeIndex];
}

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit() : super(QuoteState.initial());

  void next() {
    final i = (state.activeIndex + 1) % state.quotes.length;
    emit(state.copyWith(activeIndex: i));
  }

  void jumpTo(int index) {
    if (index < 0 || index >= state.quotes.length) return;
    emit(state.copyWith(activeIndex: index));
  }

  void shuffleNew() {
    final pool = List<Quote>.from(state.quotes)..shuffle(Random());
    emit(QuoteState(quotes: pool, activeIndex: 0));
  }
}
