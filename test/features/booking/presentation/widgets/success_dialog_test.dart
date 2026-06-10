import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp(int count) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog(
              context: ctx,
              builder: (_) => SuccessDialog(count: count),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  group('SuccessDialog', () {
    testWidgets('renders check icon', (tester) async {
      await tester.pumpWidget(_buildApp(2));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('closes when OK is tapped', (tester) async {
      await tester.pumpWidget(_buildApp(1));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(SuccessDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(SuccessDialog), findsNothing);
    });

    testWidgets('renders for count = 1 without crash', (tester) async {
      await tester.pumpWidget(_buildApp(1));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('renders for count = 4 without crash', (tester) async {
      await tester.pumpWidget(_buildApp(4));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
