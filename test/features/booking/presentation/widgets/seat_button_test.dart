import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/widgets/seat_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  group('SeatButton', () {
    testWidgets('renders seat number', (tester) async {
      await tester.pumpWidget(_wrap(SeatButton(
        number: 3,
        isDisabled: false,
        onTap: () {},
      )));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('calls onTap when enabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(SeatButton(
        number: 1,
        isDisabled: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(SeatButton));
      expect(tapped, isTrue);
    });

    testWidgets('disabled state renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const SeatButton(
        number: 2,
        isDisabled: true,
        onTap: null,
      )));
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('tap on disabled button does nothing', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(const SeatButton(
        number: 1,
        isDisabled: true,
        onTap: null,
      )));
      await tester.tap(find.byType(SeatButton));
      expect(tapped, isFalse);
    });
  });
}
