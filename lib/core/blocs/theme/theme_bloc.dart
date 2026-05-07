import 'dart:developer';

import 'package:artistplanner/core/enums/src/theme_color.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeAppChange>(
      (event, emit) => _changeTheme(event, emit, theme: event.theme),
    );
    on<ThemeGlassToggled>(
      (event, emit) => emit(state.copyWith(isGlassUI: event.enabled)),
    );
  }

  Future<void> _changeTheme(
    ThemeEvent event,
    Emitter<ThemeState> emit, {
    required ThemeColor theme,
  }) async {
    emit(state.copyWith(selectTheme: theme));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      final theme = ThemeColor.values.byName(json['themeColor'] as String);
      // Older persisted payloads may not have `isGlassUI` — default to true.
      final isGlassUI = json['isGlassUI'] as bool? ?? true;
      return ThemeState(selectTheme: theme, isGlassUI: isGlassUI);
    } on Exception catch (e) {
      log('Error deserializing state: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {
      'themeColor': state.selectTheme.name,
      'isGlassUI': state.isGlassUI,
    };
  }
}
