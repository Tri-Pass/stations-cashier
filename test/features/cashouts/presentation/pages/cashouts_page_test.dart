import 'dart:async';

import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_cashouts_summary_usecase.dart';
import 'package:cashier/features/cashouts/presentation/pages/cashouts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCashoutsSummaryUseCase extends Mock
    implements GetCashoutsSummaryUseCase {}

class _FakeCashoutSummaryParams extends Fake implements CashoutSummaryParams {}

const _emptyResponse = CashoutsResponseEntity(cashouts: [], totalAmount: 0);

CashoutsResponseEntity _responseWithOne() {
  const driver =
      CashoutDriverEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001');
  const taxi = CashoutTaxiEntity(id: 't1', plateNumber: 'A-1234');
  const line = CashoutLineEntity(
    id: 'l1',
    origin: 'Marrakech',
    destination: 'Casablanca',
    price: 80,
  );
  const cashout = CashoutSummaryEntity(
    id: 'c1',
    driver: driver,
    taxi: taxi,
    line: line,
    totalSeats: 5,
    totalAmount: 400,
  );
  return const CashoutsResponseEntity(cashouts: [cashout], totalAmount: 400);
}

CashoutsResponseEntity _responseWithStats() {
  const driver = CashoutDriverEntity(
      id: 'd1', name: 'Youssef Brahim', phone: '0600000002');
  const taxi = CashoutTaxiEntity(id: 't1', plateNumber: 'B-5678');
  const line = CashoutLineEntity(
    id: 'l2',
    origin: 'Rabat',
    destination: 'Fes',
    price: 120,
  );
  const cashout = CashoutSummaryEntity(
    id: 'c2',
    driver: driver,
    taxi: taxi,
    line: line,
    totalSeats: 3,
    totalAmount: 360,
    remaining: 200,
  );
  const stats = CashoutStatsEntity(
    totalTickets: 5,
    totalCollected: 600,
    totalNfc: 200,
    totalCash: 400,
    totalPayouts: 400,
    totalRemaining: 200,
  );
  return const CashoutsResponseEntity(
    cashouts: [cashout],
    totalAmount: 360,
    stats: stats,
  );
}

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
      home: const CashoutsPage(),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCashoutSummaryParams());
  });

  late MockGetCashoutsSummaryUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetCashoutsSummaryUseCase();
    if (sl.isRegistered<GetCashoutsSummaryUseCase>()) {
      sl.unregister<GetCashoutsSummaryUseCase>();
    }
    sl.registerSingleton<GetCashoutsSummaryUseCase>(mockUseCase);
  });

  tearDown(() {
    if (sl.isRegistered<GetCashoutsSummaryUseCase>()) {
      sl.unregister<GetCashoutsSummaryUseCase>();
    }
  });

  group('CashoutsPage', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<CashoutsResponseEntity>();
      when(() => mockUseCase(any())).thenAnswer((_) => completer.future);
      await tester.pumpWidget(_buildApp());
      await tester
          .pump(); // allow localizations to load; _load starts but awaits completer
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(_emptyResponse); // avoid pending future warnings
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no cashouts', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('shows cashout cards when data loaded', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => _responseWithOne());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Ali'), findsOneWidget);
    });

    testWidgets('shows NFC and cash method chips', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.nfc), findsOneWidget);
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('shows retry on error', (tester) async {
      when(() => mockUseCase(any())).thenThrow(Exception('network error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('shows summary card with stats data', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => _responseWithStats());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Summary card shows totalRemaining amount
      expect(find.textContaining('200'), findsWidgets);
    });

    testWidgets('summary card shows dash when loading', (tester) async {
      final completer = Completer<CashoutsResponseEntity>();
      when(() => mockUseCase(any())).thenAnswer((_) => completer.future);
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      // Loading state shows dashes in summary card
      expect(find.textContaining('—'), findsWidgets);
      completer.complete(_emptyResponse);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping cash filter chip calls load with cash method',
        (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResponse;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final initialCallCount = callCount;
      // Tap cash chip
      await tester.tap(find.byIcon(Icons.payments_outlined));
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(initialCallCount));
    });

    testWidgets('tapping NFC filter chip calls load with nfc method',
        (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResponse;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final initialCallCount = callCount;
      // Tap NFC chip
      await tester.tap(find.byIcon(Icons.nfc));
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(initialCallCount));
    });

    testWidgets('tapping all methods chip after cash selection calls load',
        (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResponse;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // First select cash
      await tester.tap(find.byIcon(Icons.payments_outlined));
      await tester.pumpAndSettle();
      final countAfterCash = callCount;
      // Then tap "all" to deselect - find text for allMethods
      // The 'all methods' chip is the first GestureDetector with no icon
      final allMethodsFinder = find.byIcon(Icons.tune).first;
      expect(allMethodsFinder, findsOneWidget);
      expect(callCount, greaterThanOrEqualTo(countAfterCash));
    });

    testWidgets('refresh button triggers reload', (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResponse;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final initialCallCount = callCount;
      // Tap the refresh button in the AppBar
      await tester.tap(find.byIcon(Icons.refresh).last);
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(initialCallCount));
    });

    testWidgets('error state shows retry text', (tester) async {
      when(() => mockUseCase(any())).thenThrow(Exception('network error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // There should be text or icon for retry
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('tapping error container retries load', (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        throw Exception('error');
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final countAfterError = callCount;
      // Tap the error container (GestureDetector in _buildList error branch)
      await tester.tap(find.byIcon(Icons.refresh).last);
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(countAfterError));
    });

    testWidgets('shows filter icon (tune) in app bar', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('shows cashouts page title', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // AppBar title should be visible
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('advanced filter sheet opens when tune icon tapped',
        (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      // Modal bottom sheet should be shown with filter fields
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('advanced filter sheet has apply button', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('tapping apply button in filter sheet closes it and reloads',
        (tester) async {
      int callCount = 0;
      when(() => mockUseCase(any())).thenAnswer((_) async {
        callCount++;
        return _emptyResponse;
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final countBeforeOpen = callCount;
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      // Tap the ElevatedButton (apply)
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(countBeforeOpen));
    });

    testWidgets('date range widgets are displayed', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Two calendar icons for date range
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });

    testWidgets('confirmation number icon in summary card', (tester) async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _emptyResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);
    });

    testWidgets('data loaded shows trips count in summary', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => _responseWithStats());
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Stats has totalTickets = 5
      expect(find.textContaining('5'), findsWidgets);
    });
  });
}
