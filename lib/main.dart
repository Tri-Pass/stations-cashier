import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/l10n/locale_notifier.dart';
import 'package:cashier/core/router/router.dart';
import 'package:cashier/core/services/sunmi_nfc_service.dart';
import 'package:cashier/core/storage/local_storage.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await setupDependencies();

  String initialLocation = '/login';
  try {
    final isAuth = await sl<AuthRepository>().isAuthenticated();
    if (isAuth) initialLocation = '/booking';
  } catch (_) {
    await sl<LocalStorage>().clear();
  }

  runApp(TaxiDriverApp(initialLocation: initialLocation));
}

class TaxiDriverApp extends StatefulWidget {
  final String initialLocation;
  const TaxiDriverApp({super.key, required this.initialLocation});

  @override
  State<TaxiDriverApp> createState() => _TaxiDriverAppState();
}

class _TaxiDriverAppState extends State<TaxiDriverApp> {
  late final GoRouter _router;
  StreamSubscription<Map<String, dynamic>>? _nfcSub;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.initialLocation);
    Future.microtask(() async {
      await WakelockPlus.enable();
      if (widget.initialLocation == '/booking') {
        sl<AuthBloc>().add(AuthCheckEvent());
      }
    });
    SunmiNfcService.ensureInitialized();
    _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
      if (event['event'] == 'CARD_FOUND') {
        final tagId = event['details']?.toString() ?? '';
        final currentPath =
            _router.routerDelegate.currentConfiguration.uri.path;
        if (tagId.isNotEmpty &&
            currentPath != '/nfc-link' &&
            !SunmiNfcService.localHandlerActive) {
          _router.push('/nfc-confirm', extra: tagId);
        }
      }
    });
  }

  @override
  void dispose() {
    _nfcSub?.cancel();
    SunmiNfcService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            SunmiNfcService.stopScanning();
            _router.go('/login');
          } else if (state is AuthAuthenticated) {
            SunmiNfcService.startScanning();
            _router.go('/home');
          }
        },
        child: ValueListenableBuilder<Locale>(
          valueListenable: sl<LocaleNotifier>(),
          builder: (_, locale, __) => MaterialApp.router(
            title: 'wetaxi.station',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(AppFontSizes.scale),
              ),
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
