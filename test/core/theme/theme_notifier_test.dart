import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeNotifier.init', () {
    test('defaults to dark when no saved value', () async {
      final notifier = ThemeNotifier();
      await notifier.init();
      expect(notifier.value, ThemeMode.dark);
    });

    test('loads saved light mode', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
      final notifier = ThemeNotifier();
      await notifier.init();
      expect(notifier.value, ThemeMode.light);
    });

    test('loads saved dark mode', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      final notifier = ThemeNotifier();
      await notifier.init();
      expect(notifier.value, ThemeMode.dark);
    });
  });

  group('ThemeNotifier.setThemeMode', () {
    test('sets light mode and persists', () async {
      final notifier = ThemeNotifier();
      await notifier.init();

      await notifier.setThemeMode(ThemeMode.light);

      expect(notifier.value, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('sets dark mode and persists', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
      final notifier = ThemeNotifier();
      await notifier.init();

      await notifier.setThemeMode(ThemeMode.dark);

      expect(notifier.value, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    test('notifies listeners on change', () async {
      final notifier = ThemeNotifier();
      await notifier.init();
      int count = 0;
      notifier.addListener(() => count++);

      await notifier.setThemeMode(ThemeMode.light);

      expect(count, 1);
    });
  });

  group('ThemeNotifier.isLight', () {
    test('returns true when light', () async {
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.isLight, isTrue);
    });

    test('returns false when dark', () async {
      final notifier = ThemeNotifier();
      await notifier.init();
      expect(notifier.isLight, isFalse);
    });
  });

  group('AppTheme', () {
    test('darkTheme returns a valid dark ThemeData', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });
  });
}
