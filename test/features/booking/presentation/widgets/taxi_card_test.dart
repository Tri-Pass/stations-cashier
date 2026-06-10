import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:cashier/features/booking/presentation/widgets/taxi_card.dart';
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
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

const _driver = DriverInfo(
  name: 'Hassan',
  phone: '0601020304',
  licenseNumber: 'LIC-001',
  balance: 100,
);

const _taxi = TaxiInfo(
  id: 't1',
  plateNumber: 'A-001-MA',
  totalSeats: 4,
  occupiedSeats: 2,
  status: 'En attente',
  driver: _driver,
);

void main() {
  group('TaxiCard', () {
    testWidgets('renders plate number', (tester) async {
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: _taxi,
        available: 2,
        onSeatCount: (_) {},
      )));
      expect(find.text('A-001-MA'), findsOneWidget);
    });

    testWidgets('renders driver name', (tester) async {
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: _taxi,
        available: 2,
        onSeatCount: (_) {},
      )));
      expect(find.text('Hassan'), findsOneWidget);
    });

    testWidgets('renders seat buttons for totalSeats', (tester) async {
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: _taxi,
        available: 2,
        onSeatCount: (_) {},
      )));
      // Should show 4 seat buttons (1, 2, 3, 4)
      expect(find.text('1'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('calls onSeatCount when enabled seat tapped', (tester) async {
      int? tappedCount;
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: _taxi,
        available: 2,
        onSeatCount: (n) => tappedCount = n,
      )));
      await tester.tap(find.text('1'));
      expect(tappedCount, 1);
    });

    testWidgets('full taxi shows 0 available with reduced opacity',
        (tester) async {
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: _taxi,
        available: 0,
        onSeatCount: (_) {},
      )));
      expect(find.byType(Opacity), findsOneWidget);
    });

    testWidgets('isFirst renders first badge', (tester) async {
      const firstTaxi = TaxiInfo(
        id: 't2',
        plateNumber: 'B-002-MA',
        totalSeats: 4,
        occupiedSeats: 0,
        status: 'En attente',
        driver: _driver,
        isFirst: true,
      );
      await tester.pumpWidget(_wrap(TaxiCard(
        taxi: firstTaxi,
        available: 4,
        onSeatCount: (_) {},
      )));
      expect(find.text('B-002-MA'), findsOneWidget);
    });
  });
}
