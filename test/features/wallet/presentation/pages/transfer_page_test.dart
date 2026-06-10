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
  });
}
