import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/widgets/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp({required Widget child}) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  group('showAppSuccess', () {
    testWidgets('shows success notification with title', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppSuccess(context, title: 'Succès'),
            child: const Text('Show'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Succès'), findsOneWidget);
      // Drain all pending timers before test ends
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('shows success icon (check_rounded)', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppSuccess(context, title: 'Done'),
            child: const Text('Show'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      // Drain pending timers
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('shows success notification with details', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppSuccess(
              context,
              title: 'Paiement réussi',
              details: [('Montant', '200 MAD'), ('Méthode', 'Cash')],
            ),
            child: const Text('Show'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Paiement réussi'), findsOneWidget);
      expect(find.textContaining('200 MAD'), findsOneWidget);
      // Drain pending timers
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('notification dismisses when tapped', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppSuccess(context, title: 'Tap to dismiss'),
            child: const Text('Show'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 400));
      // Notification shown
      expect(find.text('Tap to dismiss'), findsOneWidget);
      // Tap on notification to dismiss
      await tester.tap(find.text('Tap to dismiss'));
      await tester.pumpAndSettle();
      // After dismiss animation, overlay is removed
      expect(find.text('Tap to dismiss'), findsNothing);
      // Drain any remaining timers (success timer was 3s, we tapped before it fired)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('showAppError', () {
    testWidgets('shows error notification with message', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppError(context, message: 'Erreur réseau'),
            child: const Text('Show Error'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Error'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Erreur réseau'), findsOneWidget);
      // Drain pending timers
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error icon (error_outline_rounded)', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppError(context, message: 'Error!'),
            child: const Text('Show Error'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Error'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      // Drain pending timers
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('error notification dismisses when tapped', (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppError(context, message: 'Tap to close'),
            child: const Text('Show Error'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Error'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Tap to close'), findsOneWidget);
      await tester.tap(find.text('Tap to close'));
      await tester.pumpAndSettle();
      expect(find.text('Tap to close'), findsNothing);
      // Drain any remaining timers (error timer was 5s)
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });

  group('notification auto-dismiss', () {
    testWidgets('success notification auto-dismisses after 3 seconds',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppSuccess(context, title: 'Auto dismiss'),
            child: const Text('Show'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Auto dismiss'), findsOneWidget);
      // Fast forward 3s + dismissal animation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Auto dismiss'), findsNothing);
    });

    testWidgets('error notification auto-dismisses after 5 seconds',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showAppError(context, message: 'Error auto'),
            child: const Text('Show Error'),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Error'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Error auto'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Error auto'), findsNothing);
    });
  });
}
