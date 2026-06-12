import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/widgets/compact_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to pump a CompactDatePickerSheet directly (without bottom sheet).
Widget _buildSheet({
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  required AppLocalizations l,
  required AppColors c,
}) {
  final now = DateTime.now();
  return CompactDatePickerSheet(
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(now.year - 1),
    lastDate: lastDate ?? now,
    l: l,
    c: c,
  );
}

void main() {
  group('CompactDatePickerSheet', () {
    testWidgets('renders without crash', (tester) async {
      late AppLocalizations l;
      late AppColors c;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(l: l, c: c),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CompactDatePickerSheet), findsOneWidget);
    });

    testWidgets('shows weekday header labels (Fr locale)', (tester) async {
      late AppLocalizations l;
      late AppColors c;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(l: l, c: c),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      // French day names: Lun, Mar, Mer, Jeu, Ven, Sam, Dim
      expect(find.text('Lun'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);
    });

    testWidgets('shows navigation chevron buttons', (tester) async {
      late AppLocalizations l;
      late AppColors c;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(l: l, c: c),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerNavButton), findsWidgets);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows cancel and ok buttons', (tester) async {
      late AppLocalizations l;
      late AppColors c;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(l: l, c: c),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tapping previous month button navigates to previous month',
        (tester) async {
      late AppLocalizations l;
      late AppColors c;
      // Set a fixed date well away from firstDate to allow going previous
      final initialDate = DateTime(2024, 6, 15);
      final firstDate = DateTime(2023, 1, 1);
      final lastDate = DateTime(2024, 12, 31);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                l: l,
                c: c,
              ),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      // June 2024 should be shown
      expect(find.textContaining('juin 2024'), findsOneWidget);
      // Tap previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      // Should now show May 2024
      expect(find.textContaining('mai 2024'), findsOneWidget);
    });

    testWidgets('tapping next month button navigates to next month',
        (tester) async {
      late AppLocalizations l;
      late AppColors c;
      final initialDate = DateTime(2024, 5, 10);
      final firstDate = DateTime(2023, 1, 1);
      final lastDate = DateTime(2024, 12, 31);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                l: l,
                c: c,
              ),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('mai 2024'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.textContaining('juin 2024'), findsOneWidget);
    });

    testWidgets('tapping day cell selects that day', (tester) async {
      late AppLocalizations l;
      late AppColors c;
      final initialDate = DateTime(2024, 6, 15);
      final firstDate = DateTime(2023, 1, 1);
      final lastDate = DateTime(2024, 12, 31);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l = AppLocalizations.of(context);
          c = AppColors.of(context);
          return Scaffold(
            body: SingleChildScrollView(
              child: _buildSheet(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                l: l,
                c: c,
              ),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      // Tap day 10
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();
      // No crash, day was selected
      expect(find.byType(CompactDatePickerSheet), findsOneWidget);
    });

    testWidgets('cancel button pops without result', (tester) async {
      DateTime? result;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showCompactDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                );
              },
              child: const Text('Open'),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // Tap cancel
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('ok button pops with selected date', (tester) async {
      DateTime? result;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showCompactDatePicker(
                  context: context,
                  initialDate: DateTime(2024, 6, 15),
                  firstDate: DateTime(2023, 1, 1),
                  lastDate: DateTime(2024, 12, 31),
                );
              },
              child: const Text('Open'),
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // Tap OK
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result!.month, 6);
    });
  });

  group('DatePickerDayCell', () {
    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerDayCell(
              day: 15,
              selected: true,
              isToday: false,
              disabled: false,
              onTap: () {},
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('renders today state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerDayCell(
              day: 12,
              selected: false,
              isToday: true,
              disabled: false,
              onTap: () {},
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('renders disabled state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerDayCell(
              day: 3,
              selected: false,
              isToday: false,
              disabled: true,
              onTap: null,
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders normal state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerDayCell(
              day: 7,
              selected: false,
              isToday: false,
              disabled: false,
              onTap: () {},
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerDayCell(
              day: 20,
              selected: false,
              isToday: false,
              disabled: false,
              onTap: () => tapped = true,
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      expect(tapped, isTrue);
    });
  });

  group('DatePickerNavButton', () {
    testWidgets('renders enabled state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerNavButton(
              icon: Icons.chevron_left,
              enabled: true,
              onTap: () {},
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('renders disabled state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerNavButton(
              icon: Icons.chevron_right,
              enabled: false,
              onTap: () {},
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap when enabled and tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerNavButton(
              icon: Icons.chevron_left,
              enabled: true,
              onTap: () => tapped = true,
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePickerNavButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          final c = AppColors.of(context);
          return Scaffold(
            body: DatePickerNavButton(
              icon: Icons.chevron_left,
              enabled: false,
              onTap: () => tapped = true,
              c: c,
            ),
          );
        }),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePickerNavButton));
      expect(tapped, isFalse);
    });
  });
}
