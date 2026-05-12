import 'package:cashier/navigation/main_shell.dart';
import 'package:cashier/features/booking/presentation/pages/booking_page.dart';
import 'package:cashier/features/nfc/presentation/pages/nfc_link_page.dart';
import 'package:cashier/features/profile/presentation/pages/profile_page.dart';
import 'package:cashier/features/cashouts/presentation/pages/cashouts_page.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/features/auth/presentation/pages/login_page.dart';
import 'package:cashier/features/nfc/presentation/pages/nfc_confirm_page.dart';

GoRouter createRouter(String initialLocation) => GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        // Redirect legacy /home to /booking
        if (state.uri.path == '/home') return '/booking';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (c, s) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(
            child: child,
            location: state.uri.path,
          ),
          routes: [
            GoRoute(
              path: '/booking',
              builder: (c, s) => const CashierBookingPage(),
            ),
            GoRoute(
              path: '/nfc-link',
              builder: (c, s) => const NfcLinkPage(),
            ),
            GoRoute(
              path: '/cashouts',
              builder: (c, s) => const CashoutsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/nfc-confirm',
          builder: (c, s) => NfcConfirmPage(nfcTagId: s.extra as String),
        ), GoRoute(
          path: '/profile',
          builder: (c, s) => const ProfilePage(),
        ),
        GoRoute(
          path: '/nfc-scan',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return NfcScanPage(
              line: data['line'],
              taxi: data['taxi'],
              seatCount: data['seatCount'],
            );
          },
        ),
      ],
    );
