import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/presentation/widgets/ticket_card.dart';
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

const _line = TicketLineEntity(
  id: 'l1',
  origin: 'Marrakech',
  destination: 'Casablanca',
  price: 80,
);

const _unpaidCashTicket = TicketEntity(
  id: 'tk1',
  line: _line,
  totalSeats: 2,
  paidMethod: 'cash',
  amount: 160,
  status: 'unpaid',
);

const _paidNfcTicket = TicketEntity(
  id: 'tk2',
  line: _line,
  totalSeats: 1,
  paidMethod: 'nfc',
  amount: 80,
  status: 'paid',
);

void main() {
  group('TicketCard', () {
    testWidgets('renders route origin and destination', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(ticket: _unpaidCashTicket)));
      expect(find.textContaining('Marrakech'), findsOneWidget);
      expect(find.textContaining('Casablanca'), findsOneWidget);
    });

    testWidgets('renders amount', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(ticket: _unpaidCashTicket)));
      expect(find.textContaining('160'), findsWidgets);
    });

    testWidgets('shows cashout button for unpaid cash ticket', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(
        ticket: _unpaidCashTicket,
        onCashout: () {},
      )));
      // ElevatedButton.icon returns _ElevatedButtonWithIcon (private subtype), use predicate
      expect(
        find.byWidgetPredicate((w) => w is ElevatedButton),
        findsOneWidget,
      );
    });

    testWidgets('no cashout button for nfc paid ticket', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(
        ticket: _paidNfcTicket,
        onCashout: null,
      )));
      expect(
        find.byWidgetPredicate((w) => w is ElevatedButton),
        findsNothing,
      );
    });

    testWidgets('shows NFC icon for nfc ticket', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(ticket: _paidNfcTicket)));
      expect(find.byIcon(Icons.nfc), findsOneWidget);
    });

    testWidgets('calls onCashout when cashout button tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(TicketCard(
        ticket: _unpaidCashTicket,
        onCashout: () => tapped = true,
      )));
      await tester.tap(find.byWidgetPredicate((w) => w is ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('shows spinner when cashinOut is true', (tester) async {
      await tester.pumpWidget(_wrap(TicketCard(
        ticket: _unpaidCashTicket,
        onCashout: () {},
        cashinOut: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    group('TicketEntity', () {
      test('isCash is true for cash method', () {
        expect(_unpaidCashTicket.isCash, isTrue);
      });

      test('isCash is false for nfc method', () {
        expect(_paidNfcTicket.isCash, isFalse);
      });

      test('isUnpaid is true for unpaid status', () {
        expect(_unpaidCashTicket.isUnpaid, isTrue);
      });

      test('copyWith overrides status', () {
        final paid = _unpaidCashTicket.copyWith(status: 'paid');
        expect(paid.isUnpaid, isFalse);
        expect(paid.amount, _unpaidCashTicket.amount);
      });
    });
  });
}
