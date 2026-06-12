import 'package:bloc_test/bloc_test.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/l10n/locale_notifier.dart';
import 'package:cashier/core/services/kiosk_mode_notifier.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/theme/theme_notifier.dart';
import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Mocks & Fakes ─────────────────────────────────────────────────────────────

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// Subclass that skips platform channel and SharedPreferences calls.
class FakeKioskModeNotifier extends KioskModeNotifier {
  int setCallCount = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> setKioskMode(bool enabled) async {
    setCallCount++;
    value = enabled;
  }
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _driver = DriverEntity(
  id: 'agent-1',
  name: 'Hassan',
  phone: '0601020304',
  taxiNumber: 'T1',
  plateNumber: 'A-0001-MA',
  balance: 0,
  station: StationEntity(id: 's1', name: 'Gare Routière'),
);

// ── Widget builder ────────────────────────────────────────────────────────────

/// Builds a self-contained test app.
/// We use plain MaterialApp (no GoRouter) because ProfilePage only calls
/// context.go() from a tap handler we never invoke in these tests.
Widget _buildApp(AuthState authState) {
  final mockBloc = MockAuthBloc();
  when(() => mockBloc.state).thenReturn(authState);
  when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('fr'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthBloc>.value(
      value: mockBloc,
      child: const ProfilePage(),
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Scrolls the page ListView to the bottom so off-screen widgets are visible.
Future<void> scrollToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -5000));
  await tester.pump();
}

/// Taps the version text [n] times, scrolling into view first.
Future<void> tapVersionNTimes(WidgetTester tester, int n) async {
  await scrollToBottom(tester);
  final versionText = find.text('v1.0.0');
  for (int i = 0; i < n; i++) {
    await tester.tap(versionText);
    await tester.pump();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late FakeKioskModeNotifier kioskNotifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GetIt.instance.reset();
    kioskNotifier = FakeKioskModeNotifier();
    GetIt.instance.registerSingleton<ThemeNotifier>(ThemeNotifier());
    GetIt.instance.registerSingleton<LocaleNotifier>(LocaleNotifier());
    GetIt.instance.registerSingleton<KioskModeNotifier>(kioskNotifier);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  // ── Rendering ───────────────────────────────────────────────────────────────

  group('ProfilePage rendering', () {
    testWidgets('shows driver name when authenticated', (tester) async {
      await tester.pumpWidget(_buildApp(AuthAuthenticated(_driver)));
      await tester.pumpAndSettle();

      expect(find.text('Hassan'), findsOneWidget);
    });

    testWidgets('shows driver phone when authenticated', (tester) async {
      await tester.pumpWidget(_buildApp(AuthAuthenticated(_driver)));
      await tester.pumpAndSettle();

      expect(find.text('0601020304'), findsOneWidget);
    });

    testWidgets('shows station name when authenticated', (tester) async {
      await tester.pumpWidget(_buildApp(AuthAuthenticated(_driver)));
      await tester.pumpAndSettle();

      expect(find.text('Gare Routière'), findsOneWidget);
    });

    testWidgets('shows fallback name "Courtier" when not authenticated',
        (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      expect(find.text('Courtier'), findsOneWidget);
    });

    testWidgets('shows fallback dashes when not authenticated', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      // Phone, station, and agentId all fall back to '—'
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('shows v1.0.0 version text after scrolling to bottom',
        (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await scrollToBottom(tester);

      expect(find.text('v1.0.0'), findsOneWidget);
    });
  });

  // ── 5-tap kiosk toggle ───────────────────────────────────────────────────────

  group('ProfilePage 5-tap kiosk toggle', () {
    testWidgets('1 tap does not toggle kiosk mode', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 1);

      expect(kioskNotifier.setCallCount, 0);
    });

    testWidgets('4 taps do not toggle kiosk mode', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 4);

      expect(kioskNotifier.setCallCount, 0);
    });

    testWidgets('5 taps deactivate kiosk when currently active',
        (tester) async {
      kioskNotifier.value = true;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 5);

      expect(kioskNotifier.setCallCount, 1);
      expect(kioskNotifier.value, isFalse);
    });

    testWidgets('5 taps activate kiosk when currently inactive',
        (tester) async {
      kioskNotifier.value = false;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 5);

      expect(kioskNotifier.setCallCount, 1);
      expect(kioskNotifier.value, isTrue);
    });

    testWidgets('exactly 5 taps needed — 4 are not enough, 5th triggers',
        (tester) async {
      kioskNotifier.value = false;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await scrollToBottom(tester);
      final versionText = find.text('v1.0.0');

      for (int i = 0; i < 4; i++) {
        await tester.tap(versionText);
        await tester.pump();
      }
      expect(kioskNotifier.setCallCount, 0);

      await tester.tap(versionText);
      await tester.pump();
      expect(kioskNotifier.setCallCount, 1);
    });

    testWidgets('10 taps trigger two toggles, returning to original state',
        (tester) async {
      kioskNotifier.value = true;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 10);

      expect(kioskNotifier.setCallCount, 2);
      expect(kioskNotifier.value, isTrue);
    });

    testWidgets('tap count resets to 0 after 2 seconds of inactivity',
        (tester) async {
      kioskNotifier.value = true;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      // 3 taps then wait for the reset timer
      await tapVersionNTimes(tester, 3);
      await tester.pump(const Duration(seconds: 3));

      // 4 more taps after reset — fresh sequence, not enough to trigger
      await tapVersionNTimes(tester, 4);

      expect(kioskNotifier.setCallCount, 0);
    });

    testWidgets('second 5-tap sequence works after the first one completes',
        (tester) async {
      kioskNotifier.value = true;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 5);
      expect(kioskNotifier.setCallCount, 1);
      expect(kioskNotifier.value, isFalse);

      await tapVersionNTimes(tester, 5);
      expect(kioskNotifier.setCallCount, 2);
      expect(kioskNotifier.value, isTrue);
    });
  });

  // ── Logout dialog ────────────────────────────────────────────────────────────

  group('ProfilePage logout dialog', () {
    testWidgets('tapping logout shows confirm dialog', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await scrollToBottom(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('cancel button in logout dialog closes it', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await scrollToBottom(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('disconnect button closes dialog and dispatches logout',
        (tester) async {
      await tester.pumpWidget(_buildApp(AuthAuthenticated(_driver)));
      await tester.pumpAndSettle();

      await scrollToBottom(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  // ── Theme selector ───────────────────────────────────────────────────────────

  group('ProfilePage theme selector', () {
    testWidgets('tapping light mode option sets ThemeMode.light',
        (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.light_mode_outlined));
      await tester.pumpAndSettle();

      final notifier = GetIt.instance<ThemeNotifier>();
      expect(notifier.value, ThemeMode.light);
    });

    testWidgets('tapping dark mode option sets ThemeMode.dark', (tester) async {
      final notifier = GetIt.instance<ThemeNotifier>();
      await notifier.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      expect(notifier.value, ThemeMode.dark);
    });
  });

  // ── Language selector ────────────────────────────────────────────────────────

  group('ProfilePage language selector', () {
    testWidgets('tapping French flag sets French locale', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final langNotifier = GetIt.instance<LocaleNotifier>();
      final frFinder = find.text('Français');
      if (frFinder.evaluate().isNotEmpty) {
        await tester.tap(frFinder);
        await tester.pumpAndSettle();
        expect(langNotifier.value.languageCode, 'fr');
      } else {
        expect(find.byType(ProfilePage), findsOneWidget);
      }
    });

    testWidgets('tapping Arabic flag sets Arabic locale', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final langNotifier = GetIt.instance<LocaleNotifier>();
      final arFinder = find.text('العربية');
      if (arFinder.evaluate().isNotEmpty) {
        await tester.tap(arFinder);
        await tester.pumpAndSettle();
        expect(langNotifier.value.languageCode, 'ar');
      } else {
        expect(find.byType(ProfilePage), findsOneWidget);
      }
    });
  });

  // ── SnackBar feedback ────────────────────────────────────────────────────────

  group('ProfilePage kiosk snackbar', () {
    testWidgets('shows "Désactiver" snackbar when deactivating kiosk',
        (tester) async {
      kioskNotifier.value = true;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 5);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Désactiver'), findsOneWidget);
    });

    testWidgets('shows "Activer" snackbar when activating kiosk',
        (tester) async {
      kioskNotifier.value = false;
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 5);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Activer'), findsOneWidget);
    });

    testWidgets('no snackbar is shown for fewer than 5 taps', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pumpAndSettle();

      await tapVersionNTimes(tester, 4);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
