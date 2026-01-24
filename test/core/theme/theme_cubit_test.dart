import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rga_dashboard/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(themeModeKey)).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  group('ThemeCubit', () {
    test('initial state is ThemeMode.system when no saved preference', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn(null);
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });

    test('initial state is ThemeMode.light when saved as light', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.light);
      themeCubit.close();
    });

    test('initial state is ThemeMode.dark when saved as dark', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.dark);
      themeCubit.close();
    });

    test('initial state is ThemeMode.system when saved as system', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('system');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });

    group('toggleTheme', () {
      blocTest<ThemeCubit, ThemeMode>(
        'emits ThemeMode.light when current is dark and saves to prefs',
        setUp: () {
          when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
        },
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.toggleTheme(),
        expect: () => [ThemeMode.light],
        verify: (_) {
          verify(() => mockPrefs.setString(themeModeKey, 'light')).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeMode>(
        'emits ThemeMode.dark when current is light and saves to prefs',
        setUp: () {
          when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
        },
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.toggleTheme(),
        expect: () => [ThemeMode.dark],
        verify: (_) {
          verify(() => mockPrefs.setString(themeModeKey, 'dark')).called(1);
        },
      );
    });

    group('setThemeMode', () {
      blocTest<ThemeCubit, ThemeMode>(
        'emits ThemeMode.light when set to light and saves to prefs',
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.setThemeMode(ThemeMode.light),
        expect: () => [ThemeMode.light],
        verify: (_) {
          verify(() => mockPrefs.setString(themeModeKey, 'light')).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeMode>(
        'emits ThemeMode.dark when set to dark and saves to prefs',
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
        expect: () => [ThemeMode.dark],
        verify: (_) {
          verify(() => mockPrefs.setString(themeModeKey, 'dark')).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeMode>(
        'emits ThemeMode.system when set to system and saves to prefs',
        setUp: () {
          when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
        },
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.setThemeMode(ThemeMode.system),
        expect: () => [ThemeMode.system],
        verify: (_) {
          verify(() => mockPrefs.setString(themeModeKey, 'system')).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeMode>(
        'can switch from dark to light',
        setUp: () {
          when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
        },
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.setThemeMode(ThemeMode.light),
        expect: () => [ThemeMode.light],
      );

      blocTest<ThemeCubit, ThemeMode>(
        'does not emit when setting same mode',
        setUp: () {
          when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
        },
        build: () => ThemeCubit(mockPrefs),
        act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
        expect: () => [],
      );
    });
  });

  group('isDarkMode', () {
    testWidgets('returns true when state is ThemeMode.dark', (tester) async {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
      final themeCubit = ThemeCubit(mockPrefs);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isDark = themeCubit.isDarkMode(context);
              return Text(isDark ? 'dark' : 'light');
            },
          ),
        ),
      );

      expect(find.text('dark'), findsOneWidget);
      themeCubit.close();
    });

    testWidgets('returns false when state is ThemeMode.light', (tester) async {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
      final themeCubit = ThemeCubit(mockPrefs);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isDark = themeCubit.isDarkMode(context);
              return Text(isDark ? 'dark' : 'light');
            },
          ),
        ),
      );

      expect(find.text('light'), findsOneWidget);
      themeCubit.close();
    });

    testWidgets('uses platform brightness when state is ThemeMode.system', (
      tester,
    ) async {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn(null);
      final themeCubit = ThemeCubit(mockPrefs);
      // ThemeCubit starts with ThemeMode.system

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // In test environment, platform brightness defaults to light
              final isDark = themeCubit.isDarkMode(context);
              return Text(isDark ? 'dark' : 'light');
            },
          ),
        ),
      );

      // Default test environment is light mode
      expect(find.text('light'), findsOneWidget);
      themeCubit.close();
    });
  });

  group('multiple toggles', () {
    blocTest<ThemeCubit, ThemeMode>(
      'correctly toggles multiple times and saves each time',
      setUp: () {
        when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
      },
      build: () => ThemeCubit(mockPrefs),
      act: (cubit) {
        cubit.toggleTheme(); // light -> dark
        cubit.toggleTheme(); // dark -> light
        cubit.toggleTheme(); // light -> dark
      },
      expect: () => [ThemeMode.dark, ThemeMode.light, ThemeMode.dark],
      verify: (_) {
        verify(() => mockPrefs.setString(themeModeKey, 'dark')).called(2);
        verify(() => mockPrefs.setString(themeModeKey, 'light')).called(1);
      },
    );
  });

  group('persistence', () {
    test('loads saved dark theme on initialization', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('dark');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.dark);
      themeCubit.close();
    });

    test('loads saved light theme on initialization', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('light');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.light);
      themeCubit.close();
    });

    test('defaults to system theme when no saved preference', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn(null);
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });

    test('handles invalid saved value gracefully', () {
      when(() => mockPrefs.getString(themeModeKey)).thenReturn('invalid');
      final themeCubit = ThemeCubit(mockPrefs);
      expect(themeCubit.state, ThemeMode.system);
      themeCubit.close();
    });
  });
}
