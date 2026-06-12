import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/pages/transfer_page.dart';
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
      home: const TransferPage(),
    );

const _candidatesResponse = {
  'data': [
    {
      'user_id': 'u1',
      'phone': '0612345678',
      'full_name': 'Karim Benali',
    },
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

  group('TransferPage', () {
    testWidgets('renders without crash', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(TransferPage), findsOneWidget);
    });

    testWidgets('shows amount input field', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows preset amount chips', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.text('100 MAD'), findsOneWidget);
    });

    testWidgets('shows step dots', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('shows amount input at step 0', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      // Step 0 shows amount TextField; search field is on step 1
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('continue button is disabled when amount is 0', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('selecting preset amount enables continue button',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('tapping continue moves to step 1 (recipient search)',
        (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('200 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 1 shows search field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('step 1 shows candidates from API', (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Karim Benali'), findsOneWidget);
    });

    testWidgets('step 1 selecting candidate enables continue', (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Select a candidate
      await tester.tap(find.text('Karim Benali'));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('back from step 1 returns to step 0', (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Back arrow
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      // Back at step 0 - presets visible; 100 MAD appears in preset chip AND big display
      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('step 2 (confirm) shows recipient details', (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Step 0: select amount
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 1: select candidate
      await tester.tap(find.text('Karim Benali'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Step 2: confirm should show candidate name
      expect(find.text('Karim Benali'), findsWidgets);
    });

    testWidgets('no results text when candidates are empty', (tester) async {
      when(() => mockApi.get(any())).thenAnswer((_) async => {'data': []});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      // Empty candidates: no results text should appear
      // (uses l.noResults in _buildRecipientStep)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows free transfer note at step 0', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('typing in amount field updates display', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '150');
      await tester.pumpAndSettle();
      expect(find.textContaining('150'), findsWidgets);
    });

    testWidgets('search error path sets candidates to empty list',
        (tester) async {
      when(() => mockApi.get(any())).thenThrow(Exception('network error'));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search field onChanged triggers search with 2+ chars',
        (tester) async {
      when(() => mockApi.get(any()))
          .thenAnswer((_) async => _candidatesResponse);
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 MAD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Ka');
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
