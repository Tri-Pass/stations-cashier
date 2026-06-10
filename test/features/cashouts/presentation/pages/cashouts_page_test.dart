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

final _emptyResponse =
    const CashoutsResponseEntity(cashouts: [], totalAmount: 0);

CashoutsResponseEntity _responseWithOne() {
  const driver = CashoutDriverEntity(id: 'd1', name: 'Mohamed Ali', phone: '0600000001');
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
      await tester.pump(); // allow localizations to load; _load starts but awaits completer
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(_emptyResponse); // avoid pending future warnings
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no cashouts', (tester) async {
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => _emptyResponse);
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
      when(() => mockUseCase(any()))
          .thenAnswer((_) async => _emptyResponse);
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
  });
}
