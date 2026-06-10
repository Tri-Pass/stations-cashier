import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_seat_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('NfcConfirmSeatPicker', () {
    testWidgets('renders correct number of seat buttons', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmSeatPicker(
        totalSeats: 6,
        selectedSeat: null,
        onSeatTap: (_) {},
      )));
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('calls onSeatTap with correct seat number', (tester) async {
      int? tapped;
      await tester.pumpWidget(_wrap(NfcConfirmSeatPicker(
        totalSeats: 4,
        selectedSeat: null,
        onSeatTap: (s) => tapped = s,
      )));
      await tester.tap(find.text('3'));
      expect(tapped, 3);
    });

    testWidgets('renders without selected seat', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmSeatPicker(
        totalSeats: 3,
        selectedSeat: null,
        onSeatTap: (_) {},
      )));
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders with selected seat', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmSeatPicker(
        totalSeats: 3,
        selectedSeat: 2,
        onSeatTap: (_) {},
      )));
      expect(find.text('2'), findsOneWidget);
    });
  });
}
