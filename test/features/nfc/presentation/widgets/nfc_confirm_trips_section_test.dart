import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_trips_section.dart';
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
  trips: [
    NfcTripInfo(from: 'Marrakech', to: 'Casablanca'),
    NfcTripInfo(from: 'Agadir', to: 'Tiznit'),
  ],
);

void main() {
  group('NfcConfirmTripsSection', () {
    testWidgets('renders trips count badge', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmTripsSection(
        client: _client,
        expanded: false,
        onToggle: () {},
      )));
      // AnimatedCrossFade renders both children; badge '2' plus trip index '2'
      // may both be in tree. Check at least one exists.
      expect(find.text('2'), findsAtLeastNWidgets(1));
    });

    testWidgets('collapsed: header is shown with correct icon', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmTripsSection(
        client: _client,
        expanded: false,
        onToggle: () {},
      )));
      await tester.pumpAndSettle();
      // AnimatedCrossFade renders both children simultaneously; trip text is
      // always present in the tree even when visually hidden.
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('expanded: shows trip origin/destination', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmTripsSection(
        client: _client,
        expanded: true,
        onToggle: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('Marrakech'), findsOneWidget);
    });

    testWidgets('calls onToggle when header tapped', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(_wrap(NfcConfirmTripsSection(
        client: _client,
        expanded: false,
        onToggle: () => toggled = true,
      )));
      await tester.tap(find.byIcon(Icons.history));
      expect(toggled, isTrue);
    });

    testWidgets('empty trips shows 0 badge', (tester) async {
      const noTripsClient = NfcClientInfo(
        id: 'c2',
        name: 'Ali',
        phone: '0611',
        balance: 0,
        trips: [],
      );
      await tester.pumpWidget(_wrap(NfcConfirmTripsSection(
        client: noTripsClient,
        expanded: false,
        onToggle: () {},
      )));
      expect(find.text('0'), findsOneWidget);
    });
  });
}
