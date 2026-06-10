import 'package:bloc_test/bloc_test.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

Widget _buildApp(AuthState state) {
  final bloc = MockAuthBloc();
  when(() => bloc.state).thenReturn(state);

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
    home: BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const LoginPage(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthEvent());
  });

  group('LoginPage rendering', () {
    testWidgets('renders STATION label', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pump(); // allow async localization delegate to complete
      expect(find.text('S T A T I O N'), findsOneWidget);
    });

    testWidgets('renders phone and password fields', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pump();
      // Two TextFields: phone + password
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('renders connect button', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(_buildApp(AuthLoading()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginPage submit', () {
    testWidgets('does not submit when fields are empty', (tester) async {
      final bloc = MockAuthBloc();
      when(() => bloc.state).thenReturn(AuthInitial());
      when(() => bloc.add(any())).thenAnswer((_) {});

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
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ));

      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('submits login event when both fields filled', (tester) async {
      final bloc = MockAuthBloc();
      when(() => bloc.state).thenReturn(AuthInitial());
      when(() => bloc.add(any())).thenAnswer((_) {});

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
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const LoginPage(),
        ),
      ));
      await tester.pump();

      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      await tester.enterText(find.byWidget(fields[0]), '0600000000');
      await tester.enterText(find.byWidget(fields[1]), 'password123');
      await tester.tap(find.byType(ElevatedButton));

      verify(() => bloc.add(any(that: isA<AuthLoginEvent>()))).called(1);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(_buildApp(AuthInitial()));
      await tester.pump();
      final passwordFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((f) => f.obscureText)
          .toList();
      expect(passwordFields.length, 1);
    });
  });
}
