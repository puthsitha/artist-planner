import 'dart:developer';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends HydratedBloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LanguageAppChange>(
      (event, emit) => _changeLanguage(event, emit, locale: event.locale),
    );
  }

  static const List<Locale> supportedLocales = [Locale('en'), Locale('km')];

  Future<void> _changeLanguage(
    LanguageEvent event,
    Emitter<LanguageState> emit, {
    required Locale locale,
  }) async {
    if (!supportedLocales.contains(locale)) return;
    emit(state.copyWith(selectLanguage: locale));
  }

  @override
  LanguageState? fromJson(Map<String, dynamic> json) {
    try {
      final locale = Locale(json['languageCode'] as String);
      return LanguageState(selectLanguage: locale);
    } on Exception catch (e) {
      log('Error deserializing state: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(LanguageState state) {
    return {'languageCode': state.selectLanguage.languageCode};
  }
}
