import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing theme mode in SharedPreferences.
const String themeModeKey = 'theme_mode';

/// Cubit for managing app theme mode (light/dark/system).
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitialTheme(_prefs));

  /// Load saved theme from SharedPreferences.
  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(themeModeKey);
    return switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Toggle between light and dark mode.
  void toggleTheme() {
    final isDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _saveAndEmit(newMode);
  }

  /// Set specific theme mode.
  void setThemeMode(ThemeMode mode) {
    if (state != mode) {
      _saveAndEmit(mode);
    }
  }

  /// Save theme mode to SharedPreferences and emit new state.
  void _saveAndEmit(ThemeMode mode) {
    final themeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    _prefs.setString(themeModeKey, themeString);
    emit(mode);
  }

  /// Check if current theme is dark.
  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}
