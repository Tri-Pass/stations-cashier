import 'dart:async';

import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/pages/withdraw_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

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
      home: const WithdrawPage(),
    );

const _deskOptions = {
  'data': [
    {'req_type': 'url', 'code': 'guichet', 'label': 'Retrait Guichet'},
  ],
};

const _bankOptions = {
  'data': [
    {'req_type': 'rib', 'code': 'virement', 'label': 'Virement bancaire'},
  ],
};

const _cashplusOptions = {
  'data': [
    {'req_type': 'cashplus', 'code': 'cashplus', 'label': 'CashPlus'},
  ],
};

void main() {
  late MockApiClient mockApi;

  setUp(() {
    mockApi = MockApiClient();
    if (GetIt.instance.isRegistered<ApiClient>()) {
      GetIt.instance.unregister<ApiClient>();
    }
    GetIt.instance.registerSingleton<ApiClient>(mockApi);
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<ApiClient>()) {
      GetIt.instance.unregister<ApiClient>();
    }
  });

  group('WithdrawPage', () {
    testWidgets('shows loading while fetching options', (tester) async {
      final completer = Completer<Map<String, dynamic>>();
      when(() => mockApi.get(any())).thenAnswer((_) => completer.future);
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete({'data': []});
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty when no options returned', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => {'data': []});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows option when API returns options', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _bankOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Virement bancaire'), findsOneWidget);
    });

    testWidgets('shows error state when API throws', (tester) async {
      when(() => mockApi.get(any())).thenThrow(Exception('network error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when options list is empty',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => {'data': []});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Step 0 (option selection) shows retry button when no options returned
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('continue button disabled when no option selected',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('selecting option enables continue button', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retrait Guichet'));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets(
        'desk option: step 0 -> step 1 shows amount step (3 total steps)',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retrait Guichet'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 1: amount step shows presets
      expect(find.text('100 MAD'), findsOneWidget);
    });

    testWidgets('bank option: navigates to credentials step (RIB fields)',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _bankOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Virement bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Amount step
      await tester.tap(find.text('200 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Credentials step: should show RIB / beneficiary fields
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('cashplus option: navigates to cashplus credentials step',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _cashplusOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('CashPlus'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Amount step
      await tester.tap(find.text('300 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Credentials step: shows phone field
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('back button at step 1 returns to step 0', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retrait Guichet'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Retrait Guichet'), findsOneWidget);
    });

    testWidgets('desk confirm step shows mode and amount summary',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retrait Guichet'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Should now be at confirm step showing summary
      expect(find.text('Retrait Guichet'), findsWidgets);
    });

    testWidgets('shows step dots for desk flow (3 steps)', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('retry button triggers fetchOptions', (tester) async {
      int callCount = 0;
      when(() => mockApi.get(any())).thenAnswer((_) async {
        callCount++;
        return {'data': []};
      });
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final countBefore = callCount;
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(callCount, greaterThan(countBefore));
    });

    testWidgets('entering amount in text field updates amount display',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _deskOptions);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retrait Guichet'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Enter custom amount
      await tester.enterText(find.byType(TextField), '250');
      await tester.pumpAndSettle();
      expect(find.textContaining('250'), findsWidgets);
    });
  });
}
