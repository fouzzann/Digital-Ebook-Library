import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

class SetThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

// State
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.dark});

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences? sharedPreferences;

  ThemeBloc({this.sharedPreferences})
      : super(ThemeState(
          themeMode: (sharedPreferences?.getString('app_theme_mode') == 'light')
              ? ThemeMode.light
              : ThemeMode.dark,
        )) {
    on<ToggleTheme>((event, emit) {
      final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      sharedPreferences?.setString('app_theme_mode', newMode == ThemeMode.light ? 'light' : 'dark');
      emit(state.copyWith(themeMode: newMode));
    });

    on<SetThemeMode>((event, emit) {
      sharedPreferences?.setString('app_theme_mode', event.themeMode == ThemeMode.light ? 'light' : 'dark');
      emit(state.copyWith(themeMode: event.themeMode));
    });
  }
}
