import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_balance_card.dart';
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

const _client = NfcClientInfo(
  id: 'c1',
  name: 'Sara',
  phone: '0600000001',
  balance: 150.0,
  trips: [],
);

void main() {
  group('NfcConfirmBalanceCard', () {
    testWidgets('renders balance amount', (tester) async {
      await tester.pumpWidget(_wrap(const NfcConfirmBalanceCard(client: _client)));
      expect(find.textContaining('150.00'), findsOneWidget);
    });

    testWidgets('renders passenger name', (tester) async {
      await tester.pumpWidget(_wrap(const NfcConfirmBalanceCard(client: _client)));
      expect(find.text('Sara'), findsOneWidget);
    });

    testWidgets('renders passenger phone', (tester) async {
      await tester.pumpWidget(_wrap(const NfcConfirmBalanceCard(client: _client)));
      expect(find.text('0600000001'), findsOneWidget);
    });

    testWidgets('renders wallet icon', (tester) async {
      await tester.pumpWidget(_wrap(const NfcConfirmBalanceCard(client: _client)));
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });
  });
}
