import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/presentation/widgets/cashout_card.dart';
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

final _cashout = CashoutSummaryEntity(
  id: 'c1',
  driver: const CashoutDriverEntity(id: 'd1', name: 'Hassan', phone: '0601020304'),
  taxi: const CashoutTaxiEntity(id: 't1', plateNumber: 'A-001-MA'),
  line: const CashoutLineEntity(id: 'l1', origin: 'Marrakech', destination: 'Casablanca', price: 80),
  totalSeats: 4,
  totalAmount: 320,
  cashAmount: 240,
  nfcAmount: 80,
);

void main() {
  group('CashoutCard', () {
    testWidgets('renders driver name', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(cashout: _cashout)));
      expect(find.text('Hassan'), findsOneWidget);
    });

    testWidgets('renders driver phone', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(cashout: _cashout)));
      expect(find.text('0601020304'), findsOneWidget);
    });

    testWidgets('renders total amount', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(cashout: _cashout)));
      expect(find.textContaining('320'), findsWidgets);
    });

    testWidgets('renders plate number', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(cashout: _cashout)));
      expect(find.text('A-001-MA'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(CashoutCard(
        cashout: _cashout,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(CashoutCard));
      expect(tapped, isTrue);
    });

    testWidgets('cash-only filter hides NFC amount tile', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(
        cashout: _cashout,
        filter: 'cash',
      )));
      expect(find.byIcon(Icons.nfc), findsNothing);
    });

    testWidgets('nfc-only filter hides cash amount tile', (tester) async {
      await tester.pumpWidget(_wrap(CashoutCard(
        cashout: _cashout,
        filter: 'nfc',
      )));
      expect(find.byIcon(Icons.payments_outlined), findsNothing);
    });
  });
}
