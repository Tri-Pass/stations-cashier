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
      when(() => mockApi.get(any())).thenAnswer((_) async => {
            'data': [
              {'req_type': 'rib', 'code': 'virement', 'label': 'Virement bancaire'},
            ]
          });
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

    testWidgets('shows retry button when options list is empty', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => {'data': []});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Step 0 (option selection) shows retry button when no options returned
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
