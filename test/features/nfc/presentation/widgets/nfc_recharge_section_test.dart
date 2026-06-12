import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_recharge_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _TickerBuilder extends StatefulWidget {
  final Widget Function(BuildContext, TickerProvider) builder;
  const _TickerBuilder({required this.builder});

  @override
  State<_TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<_TickerBuilder>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => widget.builder(context, this);
}

Widget _buildApp({
  RechargeInput input = RechargeInput.nfc,
  RechargeState rechargeState = RechargeState.idle,
  VoidCallback? onScan,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  ValueChanged<RechargeInput>? onInputChanged,
}) {
  final amountCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('fr'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: _TickerBuilder(
        builder: (ctx, vsync) {
          final ctrl = AnimationController(
            vsync: vsync,
            duration: const Duration(milliseconds: 1400),
          );
          final anim = Tween<double>(begin: 0.85, end: 1.0)
              .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
          return SingleChildScrollView(
            child: NfcRechargeSection(
              input: input,
              rechargeState: rechargeState,
              amountCtrl: amountCtrl,
              phoneCtrl: phoneCtrl,
              passenger: null,
              recharging: false,
              pulseAnim: anim,
              onInputChanged: onInputChanged ?? (_) {},
              onScan: onScan ?? () {},
              onCancel: onCancel ?? () {},
              onConfirm: onConfirm ?? () {},
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('NfcRechargeSection idle state', () {
    testWidgets('renders amount field', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows scan-and-charge button when idle', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(
          find.byWidgetPredicate((w) => w is ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onScan when button tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(_buildApp(onScan: () => called = true));
      await tester.pump();
      await tester.tap(find.byWidgetPredicate((w) => w is ElevatedButton));
      expect(called, isTrue);
    });

    testWidgets('renders NFC and phone sub-tabs', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byIcon(Icons.nfc), findsWidgets);
      expect(find.byIcon(Icons.phone_outlined), findsWidgets);
    });
  });

  group('NfcRechargeSection scanning state', () {
    testWidgets('shows cancel button while scanning', (tester) async {
      await tester.pumpWidget(_buildApp(rechargeState: RechargeState.scanning));
      await tester.pump();
      expect(
          find.byWidgetPredicate((w) => w is OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onCancel when cancel tapped', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_buildApp(
        rechargeState: RechargeState.scanning,
        onCancel: () => cancelled = true,
      ));
      await tester.pump();
      await tester.tap(find.byWidgetPredicate((w) => w is OutlinedButton));
      expect(cancelled, isTrue);
    });
  });

  group('NfcRechargeSection phone mode', () {
    testWidgets('renders phone field when in phone mode', (tester) async {
      await tester.pumpWidget(_buildApp(input: RechargeInput.phone));
      await tester.pump();
      // Should have amount field + phone field
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
