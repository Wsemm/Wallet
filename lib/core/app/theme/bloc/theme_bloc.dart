import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/core/app/helper/cache_helper.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<SetDefaultThemeEvent>(_setDefaultTheme);
    on<ChangeThemeEvent>(_changeTheme);
  }
  _setDefaultTheme(SetDefaultThemeEvent event, Emitter<ThemeState> emit) {
    bool? isDark = CacheHelper().getData(key: "theme");

    switch (isDark) {
      case true:
        emit(ThemeInitial(themeMode: ThemeMode.dark));
        break;
      case false:
        emit(ThemeInitial(themeMode: ThemeMode.light));
        break;

      case null:
        emit(ThemeInitial(themeMode: ThemeMode.system));
    }
  }

  _changeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) {
    switch (event.themeValue) {
      case true:
        emit(ThemeInitial(themeMode: ThemeMode.dark));
        CacheHelper().saveData(key: "theme", value: true);
        break;
      case false:
        emit(ThemeInitial(themeMode: ThemeMode.light));
        CacheHelper().saveData(key: "theme", value: false);
    }
  }
}
