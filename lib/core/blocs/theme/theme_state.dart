part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({
    this.selectTheme = ThemeColor.defaultTheme,
    this.isGlassUI = true,
  });

  final ThemeColor selectTheme;

  /// When `true` the app renders the real `LiquidGlassLayer` (glassmorphic).
  /// When `false` call sites should pass `fake: true` so the layer falls back
  /// to a cheaper non-glass rendering.
  final bool isGlassUI;

  ThemeState copyWith({ThemeColor? selectTheme, bool? isGlassUI}) {
    return ThemeState(
      selectTheme: selectTheme ?? this.selectTheme,
      isGlassUI: isGlassUI ?? this.isGlassUI,
    );
  }

  @override
  List<Object?> get props => [selectTheme, isGlassUI];
}
