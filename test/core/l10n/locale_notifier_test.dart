import 'package:cashier/core/l10n/locale_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleNotifier.init', () {
    test('defaults to Arabic when no saved value', () async {
      final notifier = LocaleNotifier();
      await notifier.init();
      expect(notifier.value.languageCode, 'ar');
    });

    test('loads saved French locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'fr'});
      final notifier = LocaleNotifier();
      await notifier.init();
      expect(notifier.value, const Locale('fr'));
    });

    test('loads saved Arabic locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ar'});
      final notifier = LocaleNotifier();
      await notifier.init();
      expect(notifier.value, const Locale('ar'));
    });
  });

  group('LocaleNotifier.setLocale', () {
    test('sets French locale and persists', () async {
      final notifier = LocaleNotifier();
      await notifier.init();

      await notifier.setLocale(const Locale('fr'));

      expect(notifier.value.languageCode, 'fr');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fr');
    });

    test('sets Arabic locale and persists', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'fr'});
      final notifier = LocaleNotifier();
      await notifier.init();

      await notifier.setLocale(const Locale('ar'));

      expect(notifier.value.languageCode, 'ar');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'ar');
    });

    test('notifies listeners on change', () async {
      final notifier = LocaleNotifier();
      await notifier.init();
      int count = 0;
      notifier.addListener(() => count++);

      await notifier.setLocale(const Locale('fr'));

      expect(count, 1);
    });
  });
}
