part of 'theme_bloc.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial({this.themeMode = ThemeMode.system});
  final ThemeMode themeMode;
  List<Object> get props => [this.themeMode];
}
