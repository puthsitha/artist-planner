part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({this.selectTheme = ThemeColor.defaultTheme});

  final ThemeColor selectTheme;

  ThemeState copyWith({ThemeColor? selectTheme}) {
    return ThemeState(selectTheme: selectTheme ?? this.selectTheme);
  }

  @override
  List<Object?> get props => [selectTheme];
}
