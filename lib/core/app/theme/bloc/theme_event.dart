part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeThemeEvent extends ThemeEvent {
  const ChangeThemeEvent({required this.themeValue});
  final bool themeValue;
}

class SetDefaultThemeEvent extends ThemeEvent {
  const SetDefaultThemeEvent();
}
