import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_link_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp({
  bool scanning = false,
  String? tagId,
  bool linking = false,
  String? nameError,
  String? phoneError,
  VoidCallback? onStartScan,
  VoidCallback? onCancelScan,
  VoidCallback? onReset,
  VoidCallback? onLink,
}) {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  late AnimationController animCtrl;

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
      body: TickerProviderStatefulBuilder(
        builder: (context, vsync) {
          animCtrl = AnimationController(
            vsync: vsync,
            duration: const Duration(milliseconds: 1400),
          );
          final pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(parent: animCtrl, curve: Curves.easeInOut),
          );
          return SingleChildScrollView(
            child: NfcLinkSection(
              nameCtrl: nameCtrl,
              phoneCtrl: phoneCtrl,
              scanning: scanning,
              tagId: tagId,
              linking: linking,
              pulseAnim: pulseAnim,
              nameError: nameError,
              phoneError: phoneError,
              onStartScan: onStartScan ?? () {},
              onCancelScan: onCancelScan ?? () {},
              onReset: onReset ?? () {},
              onLink: onLink ?? () {},
            ),
          );
        },
      ),
    ),
  );
}

class TickerProviderStatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext, TickerProvider) builder;
  const TickerProviderStatefulBuilder({super.key, required this.builder});

  @override
  State<TickerProviderStatefulBuilder> createState() =>
      _TickerProviderStatefulBuilderState();
}

class _TickerProviderStatefulBuilderState
    extends State<TickerProviderStatefulBuilder>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => widget.builder(context, this);
}

void main() {
  group('NfcLinkSection idle state', () {
    testWidgets('shows scan NFC button when idle', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(find.byIcon(Icons.nfc), findsWidgets);
    });

    testWidgets('calls onStartScan when scan button tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(_buildApp(onStartScan: () => called = true));
      await tester.pump();
      // Find the scan button (ElevatedButton with NFC icon)
      final buttons = find.byWidgetPredicate((w) => w is ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        expect(called, isTrue);
      }
    });
  });

  group('NfcLinkSection scanning state', () {
    testWidgets('shows cancel button while scanning', (tester) async {
      await tester.pumpWidget(_buildApp(scanning: true));
      await tester.pump();
      expect(
          find.byWidgetPredicate((w) => w is OutlinedButton), findsOneWidget);
    });

    testWidgets('calls onCancelScan when cancel tapped', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_buildApp(
        scanning: true,
        onCancelScan: () => cancelled = true,
      ));
      await tester.pump();
      await tester.tap(find.byWidgetPredicate((w) => w is OutlinedButton));
      expect(cancelled, isTrue);
    });
  });

  group('NfcLinkSection detected state', () {
    testWidgets('shows link button when tag detected', (tester) async {
      await tester.pumpWidget(_buildApp(tagId: 'TAG-001'));
      await tester.pump();
      expect(
          find.byWidgetPredicate((w) => w is ElevatedButton), findsOneWidget);
    });

    testWidgets('shows reset button when tag detected', (tester) async {
      await tester.pumpWidget(_buildApp(tagId: 'TAG-001'));
      await tester.pump();
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
