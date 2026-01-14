part of 'theme_bloc.dart';

sealed class ThemeEvent {}

class ThemeAppChange extends ThemeEvent {
  ThemeAppChange({required this.theme});
  final ThemeColor theme;
}
