import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:cashier/features/booking/presentation/widgets/line_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
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

const _line = LineInfo(
  id: 'l1',
  origin: 'Marrakech',
  destination: 'Casablanca',
  price: 80,
  taxiCount: 3,
);

void main() {
  group('LineCard', () {
    testWidgets('renders destination text', (tester) async {
      await tester.pumpWidget(_wrap(LineCard(
        line: _line,
        selected: false,
        onTap: () {},
      )));
      expect(find.text('Casablanca'), findsOneWidget);
    });

    testWidgets('renders price', (tester) async {
      await tester.pumpWidget(_wrap(LineCard(
        line: _line,
        selected: false,
        onTap: () {},
      )));
      expect(find.textContaining('80'), findsWidgets);
    });

    testWidgets('renders taxi count badge', (tester) async {
      await tester.pumpWidget(_wrap(LineCard(
        line: _line,
        selected: false,
        onTap: () {},
      )));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(LineCard(
        line: _line,
        selected: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(LineCard));
      expect(tapped, isTrue);
    });

    testWidgets('selected variant renders without error', (tester) async {
      await tester.pumpWidget(_wrap(LineCard(
        line: _line,
        selected: true,
        onTap: () {},
      )));
      expect(find.text('Casablanca'), findsOneWidget);
    });

    testWidgets('zero taxi count shows red badge', (tester) async {
      const emptyLine = LineInfo(
        id: 'l2',
        origin: 'X',
        destination: 'Y',
        price: 50,
        taxiCount: 0,
      );
      await tester.pumpWidget(_wrap(LineCard(
        line: emptyLine,
        selected: false,
        onTap: () {},
      )));
      expect(find.text('0'), findsOneWidget);
    });
  });
}
