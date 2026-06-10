import 'package:flutter/material.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/network/connectivity_service.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final _service = sl<ConnectivityService>();
  bool _wasOffline    = false;
  bool _retrying      = false;
  bool _restored      = false;
  int  _failedRetries = 0;

  @override
  void initState() {
    super.initState();
    _service.state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _service.state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    final current = _service.state.value;
    if (current == ConnectivityState.offline) {
      _wasOffline = true;
      _restored = false;
    } else if (current == ConnectivityState.online && _wasOffline) {
      _wasOffline = false;
      _restored = true;
      _failedRetries = 0;
      sl<AuthBloc>().add(AuthCheckEvent());
      Future.delayed(const Duration(milliseconds: 800), () {
        sl<BookingRefreshNotifier>().refresh();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _restored = false);
      });
    }
    setState(() {});
  }

  Future<void> _handleRetry() async {
    setState(() => _retrying = true);
    await _service.recheck();
    if (mounted) {
      setState(() {
        _retrying = false;
        if (_service.state.value == ConnectivityState.offline) {
          _failedRetries++;
        }
      });
    }
  }

  Future<void> _handleResetWifi() async {
    setState(() => _retrying = true);
    await _service.reconnectWifi();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final show = _service.state.value == ConnectivityState.offline ||
        _retrying ||
        _restored;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: IgnorePointer(
            ignoring: !show,
            child: AnimatedSlide(
              offset: show ? Offset.zero : const Offset(0, -3),
              duration: const Duration(milliseconds: 380),
              curve: show ? Curves.easeOutCubic : Curves.easeInCubic,
              child: AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 280),
                child: _ConnectivityBanner(
                  retrying:    _retrying,
                  restored:    _restored,
                  showReset:   _failedRetries >= 3,
                  onRetry:     _handleRetry,
                  onResetWifi: _handleResetWifi,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Banner widget ─────────────────────────────────────────────────────────────

class _ConnectivityBanner extends StatelessWidget {
  final bool retrying;
  final bool restored;
  final bool showReset;
  final VoidCallback onRetry;
  final VoidCallback onResetWifi;

  const _ConnectivityBanner({
    required this.retrying,
    required this.restored,
    required this.showReset,
    required this.onRetry,
    required this.onResetWifi,
  });

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final color = restored ? AppColors.green : AppColors.red;
    final icon  = restored ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final title = restored ? l.connectionRestored : l.noConnectionTitle;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  if (!restored) ...[
                    const SizedBox(height: 2),
                    Text(
                      l.noConnectionBanner,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!restored) ...[
              const SizedBox(width: 8),
              retrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : GestureDetector(
                      onTap: showReset ? onResetWifi : onRetry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          showReset ? l.resetWifi : l.retryConnection,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
