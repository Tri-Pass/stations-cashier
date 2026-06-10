import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_line_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

const _lines = [
  NfcLineInfo(id: 'l1', origin: 'Marrakech', destination: 'Casablanca', price: 80),
  NfcLineInfo(id: 'l2', origin: 'Agadir', destination: 'Tiznit', price: 40),
];

void main() {
  group('NfcConfirmLineList', () {
    testWidgets('renders all line destinations', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmLineList(
        lines: _lines,
        selectedLine: null,
        onLineSelected: (_) {},
      )));
      expect(find.textContaining('Casablanca'), findsOneWidget);
      expect(find.textContaining('Tiznit'), findsOneWidget);
    });

    testWidgets('renders price for each line', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmLineList(
        lines: _lines,
        selectedLine: null,
        onLineSelected: (_) {},
      )));
      expect(find.textContaining('80 MAD'), findsOneWidget);
      expect(find.textContaining('40 MAD'), findsOneWidget);
    });

    testWidgets('calls onLineSelected when line card tapped', (tester) async {
      NfcLineInfo? selected;
      await tester.pumpWidget(_wrap(NfcConfirmLineList(
        lines: _lines,
        selectedLine: null,
        onLineSelected: (l) => selected = l,
      )));
      await tester.tap(find.textContaining('Casablanca'));
      expect(selected?.id, 'l1');
    });

    testWidgets('selected line shows check mark', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmLineList(
        lines: _lines,
        selectedLine: _lines[0],
        onLineSelected: (_) {},
      )));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('empty list renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(NfcConfirmLineList(
        lines: const [],
        selectedLine: null,
        onLineSelected: (_) {},
      )));
      expect(find.byType(Column), findsWidgets);
    });
  });
}
