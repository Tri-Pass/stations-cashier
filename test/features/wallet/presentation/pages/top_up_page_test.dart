import 'dart:async';

import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/pages/top_up_page.dart';
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
      home: const TopUpPage(),
    );

const _options = {
  'data': [
    {'req_type': 'url', 'code': 'cmi', 'label': 'Carte bancaire'},
  ]
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

  group('TopUpPage', () {
    testWidgets('shows loading while fetching options', (tester) async {
      final completer = Completer<Map<String, dynamic>>();
      when(() => mockApi.get(any())).thenAnswer((_) => completer.future);
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete({'data': []});
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty options when API returns empty list',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => {'data': []});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows option chips when API returns options', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Carte bancaire'), findsOneWidget);
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
      // Step 0 (method selection) shows retry button when no options returned
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('shows step dots at step 0', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('continue button is disabled when no option selected',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // No option selected, button should be disabled
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('selecting option enables continue button', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Tap option card
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('tapping continue with option selected moves to step 1',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 1 shows amount presets
      expect(find.text('100 MAD'), findsOneWidget);
    });

    testWidgets('amount step shows preset chips', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('200 MAD'), findsOneWidget);
      expect(find.text('500 MAD'), findsOneWidget);
    });

    testWidgets('selecting a preset amount enables continue on step 1',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Select 100 MAD preset
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('back button at step 1 goes back to step 0', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Now at step 1, tap back arrow
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      // Back at step 0, option should be visible again
      expect(find.text('Carte bancaire'), findsOneWidget);
    });

    testWidgets('amount step to confirm step shows summary tiles',
        (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => _options);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Step 0: select option
      await tester.tap(find.text('Carte bancaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 1: select amount
      await tester.tap(find.text('200 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 2: confirm - should show summary
      expect(find.text('Carte bancaire'), findsWidgets);
    });

    testWidgets('error state shows retry textbutton', (tester) async {
      when(() => mockApi.get(any())).thenThrow(Exception('network error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('retry button calls fetchOptions again', (tester) async {
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
  });
}
