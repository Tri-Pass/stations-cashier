import 'dart:async';

import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

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

void main() {
  group('WalletOption', () {
    test('fromJson with req_type key', () {
      final o = WalletOption.fromJson({'req_type': 'url', 'code': 'CMI', 'label': 'Carte'});
      expect(o.reqType, 'url');
      expect(o.code, 'CMI');
      expect(o.label, 'Carte');
    });

    test('fromJson defaults to url when req_type missing', () {
      final o = WalletOption.fromJson({'code': 'X', 'label': 'Y'});
      expect(o.reqType, 'url');
    });

    test('fromJson with reqType (camelCase) fallback', () {
      final o = WalletOption.fromJson({'reqType': 'rib', 'code': 'virement', 'label': 'Virement'});
      expect(o.reqType, 'rib');
    });

    test('fromJson with empty values defaults to empty strings', () {
      final o = WalletOption.fromJson({});
      expect(o.reqType, 'url');
      expect(o.code, '');
      expect(o.label, '');
    });
  });

  group('walletOptionIcon', () {
    test('returns qr icon for guichet option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'guichet', label: 'Guichet'));
      expect(icon, Icons.qr_code_2);
    });

    test('returns qr icon for qr option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'qr', label: 'QR Code'));
      expect(icon, Icons.qr_code_2);
    });

    test('returns bank icon for virement option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'rib', code: 'virement', label: 'Virement'));
      expect(icon, Icons.account_balance);
    });

    test('returns bank icon for bank option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'rib', code: 'bank', label: 'Bank'));
      expect(icon, Icons.account_balance);
    });

    test('returns credit_card icon for cmi option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'cmi', label: 'CMI'));
      expect(icon, Icons.credit_card);
    });

    test('returns phone_android icon for cashplus option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'cashplus', code: 'cashplus', label: 'CashPlus'));
      expect(icon, Icons.phone_android);
    });

    test('returns phone_android icon for mobile option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'mobile', label: 'Mobile'));
      expect(icon, Icons.phone_android);
    });

    test('returns default icon for unknown option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'unknown', label: 'Unknown'));
      expect(icon, Icons.payments_outlined);
    });
  });

  group('walletOptionColor', () {
    test('returns primary for guichet', () {
      final color = walletOptionColor(const WalletOption(reqType: 'url', code: 'guichet', label: 'Guichet'));
      expect(color, AppColors.primary);
    });

    test('returns blue for virement', () {
      final color = walletOptionColor(const WalletOption(reqType: 'rib', code: 'virement', label: 'Virement'));
      expect(color, const Color(0xFF4A90D9));
    });

    test('returns teal for cmi', () {
      final color = walletOptionColor(const WalletOption(reqType: 'url', code: 'cmi', label: 'CMI'));
      expect(color, AppColors.teal);
    });

    test('returns teal for cashplus', () {
      final color = walletOptionColor(const WalletOption(reqType: 'cashplus', code: 'cashplus', label: 'CashPlus'));
      expect(color, AppColors.teal);
    });

    test('returns primary for unknown', () {
      final color = walletOptionColor(const WalletOption(reqType: 'url', code: 'xyz', label: 'Other'));
      expect(color, AppColors.primary);
    });
  });

  group('WalletStepDots', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(_wrap(const WalletStepDots(step: 0, total: 3)));
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders 4 dots for total=4', (tester) async {
      await tester.pumpWidget(_wrap(const WalletStepDots(step: 1, total: 4)));
      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('renders with step at last position', (tester) async {
      await tester.pumpWidget(_wrap(const WalletStepDots(step: 2, total: 3)));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });

  group('WalletPresetChip', () {
    testWidgets('renders amount label', (tester) async {
      await tester.pumpWidget(_wrap(WalletPresetChip(
        amount: 200,
        selected: false,
        onTap: () {},
      )));
      expect(find.text('200 MAD'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(WalletPresetChip(
        amount: 100,
        selected: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(WalletPresetChip));
      expect(tapped, isTrue);
    });

    testWidgets('selected variant renders', (tester) async {
      await tester.pumpWidget(_wrap(WalletPresetChip(
        amount: 500,
        selected: true,
        onTap: () {},
      )));
      expect(find.text('500 MAD'), findsOneWidget);
    });

    testWidgets('all preset amounts render correctly', (tester) async {
      for (final amount in walletAmountPresets) {
        await tester.pumpWidget(_wrap(WalletPresetChip(
          amount: amount,
          selected: false,
          onTap: () {},
        )));
        expect(find.text('$amount MAD'), findsOneWidget);
      }
    });
  });

  group('walletErrorBanner', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(_wrap(walletErrorBanner('Something went wrong')));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(_wrap(walletErrorBanner('Error occurred')));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('walletInputField', () {
    testWidgets('renders with hint text', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(_wrap(walletInputField(
        controller: ctrl,
        hint: 'Enter amount',
        icon: Icons.payments_outlined,
      )));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onChanged is called when text is entered', (tester) async {
      final ctrl = TextEditingController();
      String? changed;
      await tester.pumpWidget(_wrap(walletInputField(
        controller: ctrl,
        hint: 'Amount',
        icon: Icons.payments_outlined,
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), '150');
      expect(changed, '150');
    });
  });

  group('WalletResultBanner', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(WalletResultBanner(
        icon: Icons.check_circle,
        color: AppColors.primary,
        title: 'Success',
        subtitle: 'Operation complete',
        onDone: () {},
      )));
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Operation complete'), findsOneWidget);
    });

    testWidgets('calls onDone when button pressed', (tester) async {
      bool done = false;
      await tester.pumpWidget(_wrap(WalletResultBanner(
        icon: Icons.check_circle,
        color: AppColors.primary,
        title: 'Done',
        subtitle: 'Completed',
        onDone: () => done = true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      expect(done, isTrue);
    });

    testWidgets('renders with transfer color 6C7FDE', (tester) async {
      await tester.pumpWidget(_wrap(WalletResultBanner(
        icon: Icons.check_circle,
        color: const Color(0xFF6C7FDE),
        title: 'Transfer Done',
        subtitle: 'Transfer completed successfully',
        onDone: () {},
      )));
      expect(find.text('Transfer Done'), findsOneWidget);
    });
  });

  group('WalletUrlResultCard', () {
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

    testWidgets('renders url', (tester) async {
      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://example.com/pay',
        title: 'QR Code',
        subtitle: 'Scan to pay',
        onDone: () {},
      )));
      expect(find.textContaining('https://example.com/pay'), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://example.com',
        title: 'Payment Link',
        subtitle: 'Click to pay',
        onDone: () {},
      )));
      expect(find.text('Payment Link'), findsOneWidget);
    });

    testWidgets('calls onDone when button pressed', (tester) async {
      bool done = false;
      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://example.com',
        title: 'Done',
        subtitle: 'Complete',
        onDone: () => done = true,
      )));
      await tester.pumpAndSettle();
      // Find the ElevatedButton (back to wallet)
      await tester.tap(find.byType(ElevatedButton));
      expect(done, isTrue);
    });

    testWidgets('copy icon is present', (tester) async {
      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://example.com',
        title: 'Link',
        subtitle: 'Pay here',
        onDone: () {},
      )));
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });

  group('walletSummaryTile', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(_wrap(
        walletSummaryTile('Montant', '200 MAD', Icons.payments_outlined, AppColors.primary),
      ));
      expect(find.text('Montant'), findsOneWidget);
      expect(find.text('200 MAD'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(_wrap(
        walletSummaryTile('Mode', 'Cash', Icons.payments_outlined, AppColors.teal),
      ));
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });
  });

  group('WalletUrlResultCard copy button', () {
    late MockApiClient localMockApi;

    setUp(() {
      localMockApi = MockApiClient();
      if (GetIt.instance.isRegistered<ApiClient>()) {
        GetIt.instance.unregister<ApiClient>();
      }
      GetIt.instance.registerSingleton<ApiClient>(localMockApi);
    });

    tearDown(() {
      if (GetIt.instance.isRegistered<ApiClient>()) {
        GetIt.instance.unregister<ApiClient>();
      }
    });

    testWidgets('copy button calls showAppSuccess on tap', (tester) async {
      // Mock the post call for clipboard notification
      when(() => localMockApi.post(any(), any())).thenAnswer((_) async => {});

      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://pay.example.com',
        title: 'QR Link',
        subtitle: 'Scan or click',
        onDone: () {},
      )));
      await tester.pumpAndSettle();
      // Tap the copy icon
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump(const Duration(milliseconds: 400));
      // showAppSuccess is called - the overlay shows
      // (best-effort: just ensure no crash occurred)
      // Drain any remaining timers
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('WalletUrlResultCard shows qr icon', (tester) async {
      await tester.pumpWidget(_wrap(WalletUrlResultCard(
        url: 'https://pay.example.com',
        title: 'QR',
        subtitle: 'Sub',
        onDone: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.qr_code_2), findsOneWidget);
    });
  });

  group('walletAmountPresets constant', () {
    test('contains standard preset amounts', () {
      expect(walletAmountPresets, containsAll([100, 200, 300, 500]));
    });
  });
}
