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

final _emptyResult = DriverTicketsEntity(
  driver: const DriverInfoEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001'),
  tickets: [],
  summary: const TicketsSummaryEntity(
    totalTickets: 0,
    totalCashAmount: 0,
    totalNfcAmount: 0,
    totalAmount: 0,
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
      await tester.pump(); // allow localizations to load; _load starts but awaits completer
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(_emptyResult);
      await tester.pumpAndSettle();
    });

    testWidgets('shows driver name in app bar', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Ali'), findsOneWidget);
    });

    testWidgets('shows no loading after data loads', (tester) async {
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _emptyResult);
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
      when(() => mockGetTickets(any()))
          .thenAnswer((_) async => _emptyResult);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
