import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/wallet/presentation/widgets/wallet_flow_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  group('walletOptionIcon', () {
    test('returns qr icon for guichet option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'guichet', label: 'Guichet'));
      expect(icon, Icons.qr_code_2);
    });

    test('returns bank icon for virement option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'rib', code: 'virement', label: 'Virement'));
      expect(icon, Icons.account_balance);
    });

    test('returns default icon for unknown option', () {
      final icon = walletOptionIcon(const WalletOption(reqType: 'url', code: 'unknown', label: 'Unknown'));
      expect(icon, Icons.payments_outlined);
    });
  });

  group('WalletStepDots', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(_wrap(const WalletStepDots(step: 0, total: 3)));
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
  });

  group('walletErrorBanner', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(_wrap(walletErrorBanner('Something went wrong')));
      expect(find.text('Something went wrong'), findsOneWidget);
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
  });

  group('walletSummaryTile', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(_wrap(
        walletSummaryTile('Montant', '200 MAD', Icons.payments_outlined, AppColors.primary),
      ));
      expect(find.text('Montant'), findsOneWidget);
      expect(find.text('200 MAD'), findsOneWidget);
    });
  });
}
