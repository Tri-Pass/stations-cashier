import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('NfcModeSelector', () {
    testWidgets('renders two tabs', (tester) async {
      await tester.pumpWidget(_wrap(NfcModeSelector(children: [
        NfcModeTab(
          label: 'Liaison',
          icon: Icons.link_rounded,
          active: true,
          activeColor: AppColors.primary,
          onTap: () {},
        ),
        NfcModeTab(
          label: 'Recharge',
          icon: Icons.bolt_rounded,
          active: false,
          activeColor: AppColors.primary,
          onTap: () {},
        ),
      ])));
      expect(find.text('Liaison'), findsOneWidget);
      expect(find.text('Recharge'), findsOneWidget);
    });

    testWidgets('calls onTap for inactive tab', (tester) async {
      bool rechargeTapped = false;
      await tester.pumpWidget(_wrap(NfcModeSelector(children: [
        NfcModeTab(
          label: 'Liaison',
          icon: Icons.link_rounded,
          active: true,
          activeColor: AppColors.primary,
          onTap: () {},
        ),
        NfcModeTab(
          label: 'Recharge',
          icon: Icons.bolt_rounded,
          active: false,
          activeColor: AppColors.primary,
          onTap: () => rechargeTapped = true,
        ),
      ])));
      await tester.tap(find.text('Recharge'));
      expect(rechargeTapped, isTrue);
    });
  });

  group('NfcModeTab', () {
    testWidgets('active tab renders with label', (tester) async {
      await tester.pumpWidget(_wrap(Row(children: [
        NfcModeTab(
          label: 'Test',
          icon: Icons.nfc,
          active: true,
          activeColor: AppColors.primary,
          onTap: () {},
        ),
      ])));
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
