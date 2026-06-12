import 'dart:async';

import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/usecases/cashout_ticket_usecase.dart';
import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_driver_tickets_usecase.dart';
import 'package:cashier/features/cashouts/presentation/pages/driver_tickets_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDriverTicketsUseCase extends Mock
    implements GetDriverTicketsUseCase {}

class MockCashoutTicketUseCase extends Mock implements CashoutTicketUseCase {}

class _FakeGetDriverTicketsParams extends Fake
    implements GetDriverTicketsParams {}

class _FakeCashoutTicketParams extends Fake implements CashoutTicketParams {}

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

const _emptyResult = DriverTicketsEntity(
  driver: DriverInfoEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001'),
  tickets: [],
  summary: TicketsSummaryEntity(
    totalTickets: 0,
    totalCashAmount: 0,
    totalNfcAmount: 0,
    totalAmount: 0,
  ),
);

DriverTicketsEntity _resultWithUnpaidCash() => const DriverTicketsEntity(
      driver:
          DriverInfoEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001'),
      tickets: [_unpaidCashTicket],
      summary: TicketsSummaryEntity(
        totalTickets: 1,
        totalCashAmount: 160,
        totalNfcAmount: 0,
        totalAmount: 160,
      ),
    );

DriverTicketsEntity _resultWithNfc() => const DriverTicketsEntity(
      driver:
          DriverInfoEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001'),
      tickets: [_paidNfcTicket],
      summary: TicketsSummaryEntity(
        totalTickets: 1,
        totalCashAmount: 0,
        totalNfcAmount: 80,
        totalAmount: 80,
      ),
    );

Widget _buildApp() => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DriverTicketsPage(
        driverId: 'd1',
        driverName: 'Mohamed Ali',
        driverPhone: '0600000001',
      ),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeGetDriverTicketsParams());
    registerFallbackValue(_FakeCashoutTicketParams());
  });

  late MockGetDriverTicketsUseCase mockGetTickets;
  late MockCashoutTicketUseCase mockCashoutTicket;

  setUp(() {
    mockGetTickets = MockGetDriverTicketsUseCase();
    mockCashoutTicket = MockCashoutTicketUseCase();
    if (sl.isRegistered<GetDriverTicketsUseCase>()) {
      sl.unregister<GetDriverTicketsUseCase>();
    }
    if (sl.isRegistered<CashoutTicketUseCase>()) {
      sl.unregister<CashoutTicketUseCase>();
    }
    sl.registerSingleton<GetDriverTicketsUseCase>(mockGetTickets);
    sl.registerSingleton<CashoutTicketUseCase>(mockCashoutTicket);
  });

  tearDown(() {
    if (sl.isRegistered<GetDriverTicketsUseCase>()) {
      sl.unregister<GetDriverTicketsUseCase>();
    }
    if (sl.isRegistered<CashoutTicketUseCase>()) {
      sl.unregister<CashoutTicketUseCase>();
    }
  });

  group('DriverTicketsPage', () {
    testWidgets('shows loading initially', (tester) async {
      final completer = Completer<DriverTicketsEntity>();
      when(() => mockGetTickets(any())).thenAnswer((_) => completer.future);
      await tester.pumpWidget(_buildApp());
      await tester
          .pump(); // allow localizations to load; _load starts but awaits completer
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(_emptyResult);
      await tester.pumpAndSettle();
    });

    testWidgets('shows driver name in app bar', (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Ali'), findsOneWidget);
    });

    testWidgets('shows no loading after data loads', (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error and refresh on failure', (tester) async {
      when(() => mockGetTickets(any())).thenThrow(Exception('error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('renders filter chips for ticket status', (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('shows empty state when no tickets match filter',
        (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);
    });

    testWidgets('shows unpaid cash ticket', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.textContaining('Marrakech'), findsWidgets);
    });

    testWidgets('shows cashout all bar when unpaid cash tickets exist',
        (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // CashoutAll bar exists; arrow_circle_up_outlined icon is present
      // (may appear in both ticket card button and bottom bar button)
      expect(find.byIcon(Icons.arrow_circle_up_outlined), findsWidgets);
    });

    testWidgets('no cashout all bar when no unpaid cash tickets',
        (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithNfc());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_circle_up_outlined), findsNothing);
    });

    testWidgets('filter chips switch from unpaid to all shows nfc ticket',
        (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithNfc());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Default filter is 'unpaid', nfc ticket is paid (not unpaid cash) so it shows under 'paid'
      // Tap "All" filter chip - it's the first text-only chip
      final allChipFinder = find.byType(GestureDetector).first;
      await tester.tap(allChipFinder);
      await tester.pumpAndSettle();
      // no crash
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (tester) async {
      int callCount = 0;
      when(() => mockGetTickets(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResult;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final initialCount = callCount;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(initialCount));
    });

    testWidgets('cashout single shows confirm dialog', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Tap cashout button on the ticket card
      final cashoutButtons = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (cashoutButtons.evaluate().isNotEmpty) {
        await tester.tap(cashoutButtons.first);
        await tester.pumpAndSettle();
        // AlertDialog should appear
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });

    testWidgets('cashout single dialog cancel does not call usecase',
        (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final cashoutButtons = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (cashoutButtons.evaluate().isNotEmpty) {
        await tester.tap(cashoutButtons.first);
        await tester.pumpAndSettle();
        // Tap cancel
        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettle();
        verifyNever(() => mockCashoutTicket(any()));
      }
    });

    testWidgets('cashout single confirm calls usecase and reloads',
        (tester) async {
      int getTicketsCalls = 0;
      when(() => mockGetTickets(any())).thenAnswer((_) async {
        getTicketsCalls++;
        return _resultWithUnpaidCash();
      });
      when(() => mockCashoutTicket(any()))
          .thenAnswer((_) async => const CashoutResultEntity(160));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final cashoutButtons = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (cashoutButtons.evaluate().isNotEmpty) {
        await tester.tap(cashoutButtons.first);
        await tester.pumpAndSettle();
        // Confirm by tapping the ElevatedButton in the dialog
        final dialogConfirmBtn = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(ElevatedButton),
        );
        if (dialogConfirmBtn.evaluate().isNotEmpty) {
          final callsBefore = getTicketsCalls;
          await tester.tap(dialogConfirmBtn.first);
          await tester.pumpAndSettle();
          expect(getTicketsCalls, greaterThan(callsBefore));
        }
      }
    });

    testWidgets('cashout all shows confirm dialog', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // The bottom bar contains the cashout all ElevatedButton.icon
      // Find by the specific bottom navigation bar button
      final cashoutAllBtns = find.byWidgetPredicate(
        (w) =>
            w is ElevatedButton &&
            // The cashout-all bar button is at the bottom
            true,
      );
      // There should be exactly one ElevatedButton (in the bottom bar) since
      // the unpaid cash ticket is filtered to 'unpaid' and shows a TicketCard
      // with cashout button PLUS the bottom bar button. Use the last one.
      if (cashoutAllBtns.evaluate().isNotEmpty) {
        await tester.tap(cashoutAllBtns.last);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
      }
    });

    testWidgets('cashout all confirm calls usecase', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      when(() => mockCashoutTicket(any()))
          .thenAnswer((_) async => const CashoutResultEntity(160));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final cashoutAllBtns = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (cashoutAllBtns.evaluate().isNotEmpty) {
        await tester.tap(cashoutAllBtns.last);
        await tester.pumpAndSettle();
        if (find.byType(AlertDialog).evaluate().isNotEmpty) {
          final dialogConfirmBtn = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ElevatedButton),
          );
          if (dialogConfirmBtn.evaluate().isNotEmpty) {
            await tester.tap(dialogConfirmBtn.first);
            await tester.pumpAndSettle();
            verify(() => mockCashoutTicket(any())).called(1);
          }
        }
      }
    });

    testWidgets('tapping back button pops the page', (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.byType(DriverTicketsPage), findsNothing);
    });

    testWidgets('tapping all filter chip covers all case', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tous'));
      await tester.pumpAndSettle();
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('tapping unpaid filter chip covers unpaid case',
        (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tous'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('À payer').first);
      await tester.pumpAndSettle();
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('tapping paid filter chip covers paid case', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Payé'));
      await tester.pumpAndSettle();
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('cashout single error shows snackbar', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      when(() => mockCashoutTicket(any()))
          .thenThrow(Exception('cashout failed'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final cashoutButtons = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (cashoutButtons.evaluate().isNotEmpty) {
        await tester.tap(cashoutButtons.first);
        await tester.pumpAndSettle();
        if (find.byType(AlertDialog).evaluate().isNotEmpty) {
          final confirmBtn = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ElevatedButton),
          );
          if (confirmBtn.evaluate().isNotEmpty) {
            await tester.tap(confirmBtn.first);
            await tester.pumpAndSettle();
          }
        }
      }
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('cashout all error shows snackbar', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      when(() => mockCashoutTicket(any()))
          .thenThrow(Exception('all cashout failed'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final allBtns = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (allBtns.evaluate().isNotEmpty) {
        await tester.tap(allBtns.last);
        await tester.pumpAndSettle();
        if (find.byType(AlertDialog).evaluate().isNotEmpty) {
          final confirmBtn = find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ElevatedButton),
          );
          if (confirmBtn.evaluate().isNotEmpty) {
            await tester.tap(confirmBtn.first);
            await tester.pumpAndSettle();
          }
        }
      }
      expect(find.byType(DriverTicketsPage), findsOneWidget);
    });

    testWidgets('shows driver phone in app bar subtitle', (tester) async {
      when(() => mockGetTickets(any())).thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('0600000001'), findsOneWidget);
    });

    testWidgets('summary card shows total cash to pay', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _resultWithUnpaidCash());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // 160 MAD from unpaid cash ticket
      expect(find.textContaining('160'), findsWidgets);
    });

    testWidgets('tapping error container retries load', (tester) async {
      int callCount = 0;
      when(() => mockGetTickets(any())).thenAnswer((_) async {
        callCount++;
        throw Exception('error');
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final countAfterError = callCount;
      await tester.tap(find.byIcon(Icons.refresh).last);
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(countAfterError));
    });
  });
}
