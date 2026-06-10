import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/widgets/payment_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('PaymentButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(PaymentButton(
        icon: Icons.payments_outlined,
        label: 'Espèces',
        selected: false,
        onTap: () {},
      )));
      expect(find.text('Espèces'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(_wrap(PaymentButton(
        icon: Icons.payments_outlined,
        label: 'Espèces',
        selected: false,
        onTap: () {},
      )));
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(PaymentButton(
        icon: Icons.nfc,
        label: 'NFC',
        selected: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(PaymentButton));
      expect(tapped, isTrue);
    });

    testWidgets('selected variant renders without error', (tester) async {
      await tester.pumpWidget(_wrap(PaymentButton(
        icon: Icons.nfc,
        label: 'NFC',
        selected: true,
        onTap: () {},
      )));
      expect(find.text('NFC'), findsOneWidget);
    });
  });
}
