import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/services/sunmi_nfc_service.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/usecases/get_passenger_by_nfc_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/link_nfc_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/nfc_topup_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/phone_topup_usecase.dart';
import 'package:cashier/core/services/cashier_printer.dart';
import 'package:cashier/core/widgets/app_notification.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_mode_selector.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_link_section.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_recharge_section.dart';

enum _PageMode { link, recharge }

class NfcLinkPage extends StatefulWidget {
  const NfcLinkPage({super.key});

  @override
  State<NfcLinkPage> createState() => _NfcLinkPageState();
}

class _NfcLinkPageState extends State<NfcLinkPage>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── NFC ───────────────────────────────────────────────────────────────────
  StreamSubscription<Map<String, dynamic>>? _nfcSub;
  bool _nfcStarted = false;

  // ── Mode ──────────────────────────────────────────────────────────────────
  _PageMode _mode = _PageMode.link;

  // ── Link state ────────────────────────────────────────────────────────────
  final TextEditingController _linkNameCtrl = TextEditingController();
  final TextEditingController _linkPhoneCtrl = TextEditingController();
  bool _linkScanning = false;
  String? _linkTagId;
  bool _linking = false;
  String? _linkNameError;
  String? _linkPhoneError;

  // ── Recharge state ────────────────────────────────────────────────────────
  RechargeInput _rechargeInput = RechargeInput.nfc;
  RechargeState _rechargeState = RechargeState.idle;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _rechargePhoneCtrl = TextEditingController();
  String? _rechargeTagId;
  PassengerEntity? _rechargePassenger;
  bool _recharging = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _linkNameCtrl.addListener(() => setState(() => _linkNameError = null));
    _linkPhoneCtrl.addListener(() => setState(() => _linkPhoneError = null));
    _amountCtrl.addListener(() => setState(() {}));
    _rechargePhoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _linkNameCtrl.dispose();
    _linkPhoneCtrl.dispose();
    _amountCtrl.dispose();
    _rechargePhoneCtrl.dispose();
    _stopNfc();
    super.dispose();
  }

  // ── NFC helpers ───────────────────────────────────────────────────────────

  void _startNfc(void Function(String tagId) onTag) {
    _pulseCtrl.repeat(reverse: true);
    _nfcStarted = true;
    SunmiNfcService.startScanning();
    _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
      if (event['event'] == 'CARD_FOUND' && mounted) {
        onTag(event['details']?.toString() ?? '');
      }
    });
  }

  void _stopNfc() {
    if (!_nfcStarted) return;
    _nfcStarted = false;
    SunmiNfcService.stopScanning();
    _nfcSub?.cancel();
  }

  void _stopPulse() {
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _stopNfc();
  }

  // ── Link flow ─────────────────────────────────────────────────────────────

  void _linkStartScan() {
    final nameEmpty = _linkNameCtrl.text.trim().isEmpty;
    final phoneEmpty = _linkPhoneCtrl.text.trim().isEmpty;
    if (nameEmpty || phoneEmpty) {
      setState(() {
        _linkNameError =
            nameEmpty ? AppLocalizations.of(context).fieldNameRequired : null;
        _linkPhoneError =
            phoneEmpty ? AppLocalizations.of(context).fieldPhoneRequired : null;
      });
      return;
    }
    setState(() {
      _linkScanning = true;
      _linkTagId = null;
      _linkNameError = null;
      _linkPhoneError = null;
    });
    _startNfc((tagId) {
      _stopPulse();
      setState(() {
        _linkScanning = false;
        _linkTagId = tagId;
      });
    });
  }

  void _linkCancelScan() {
    _stopPulse();
    setState(() => _linkScanning = false);
  }

  void _linkReset() {
    _stopPulse();
    setState(() {
      _linkScanning = false;
      _linkTagId = null;
      _linkNameError = null;
      _linkPhoneError = null;
    });
  }

  Future<void> _linkPassenger() async {
    if (_linkTagId == null || _linkPhoneCtrl.text.trim().isEmpty) return;
    final l = AppLocalizations.of(context);
    setState(() => _linking = true);
    try {
      final name = _linkNameCtrl.text.trim();
      await sl<LinkNfcUseCase>()(LinkNfcParams(
        phone: _linkPhoneCtrl.text.trim(),
        nfcTagId: _linkTagId!,
        name: name.isEmpty ? null : name,
      ));
      if (!mounted) return;
      showAppSuccess(context, title: l.linkSuccess);
      _linkReset();
      _linkNameCtrl.clear();
      _linkPhoneCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      showAppError(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  // ── Recharge flow ─────────────────────────────────────────────────────────

  void _rechargeScan() {
    setState(() {
      _rechargeState = RechargeState.scanning;
      _rechargeTagId = null;
      _rechargePassenger = null;
    });
    _startNfc((tagId) async {
      _stopPulse();
      setState(() {
        _rechargeTagId = tagId;
        _rechargeState = RechargeState.fetching;
      });
      try {
        final passenger = await sl<GetPassengerByNfcUseCase>()(tagId);
        if (!mounted) return;
        setState(() {
          _rechargePassenger = passenger;
          _rechargeState = RechargeState.ready;
        });
      } catch (e) {
        if (!mounted) return;
        showAppError(context, message: e.toString());
        setState(() => _rechargeState = RechargeState.idle);
      }
    });
  }

  void _rechargeCancel() {
    _stopPulse();
    setState(() {
      _rechargeState = RechargeState.idle;
      _rechargeTagId = null;
      _rechargePassenger = null;
    });
  }

  Future<void> _confirmRecharge() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    final l = AppLocalizations.of(context);

    setState(() => _recharging = true);
    try {
      final NfcTopupResult result;
      final String method;
      if (_rechargeInput == RechargeInput.nfc) {
        result = await sl<NfcTopupUseCase>()(NfcTopupParams(
          nfcTagId: _rechargeTagId!,
          amount: amount,
        ));
        method = 'NFC';
      } else {
        result = await sl<PhoneTopupUseCase>()(PhoneTopupParams(
          phone: _rechargePhoneCtrl.text.trim(),
          amount: amount,
        ));
        method = 'Téléphone';
      }
      if (!mounted) return;
      await CashierPrinter.printRecharge(
        passengerName: result.name,
        passengerPhone: result.phone,
        amount: result.amount,
        balanceBefore: result.balanceBefore,
        balanceAfter: result.balanceAfter,
        method: method,
        l: l,
      );
      if (!mounted) return;
      showAppSuccess(
        context,
        title: l.rechargeSuccess,
        details: [
          ('Montant', '${result.amount.toStringAsFixed(0)} MAD'),
          ('Téléphone', result.phone),
        ],
      );
      _rechargeCancel();
      _amountCtrl.clear();
      _rechargePhoneCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      showAppError(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _recharging = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      // appBar: AppBar(
      //   backgroundColor: c.surface,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     l.nfcLinkTitle,
      //     style: TextStyle(
      //       color: c.textPrimary,
      //       fontSize: 16,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModeSelector(l),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_mode == _PageMode.recharge)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is! AuthAuthenticated) {
                              return const SizedBox.shrink();
                            }
                            return _NfcBalanceCard(
                              driver: state.driver,
                              onWithdraw: () => context.push('/withdraw'),
                              onTransfer: () => context.push('/transfer'),
                              onTopUp: () => context.push('/topup'),
                            );
                          },
                        ),
                      if (_mode == _PageMode.recharge)
                        const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _mode == _PageMode.link
                            ? NfcLinkSection(
                                key: const ValueKey('link'),
                                nameCtrl: _linkNameCtrl,
                                phoneCtrl: _linkPhoneCtrl,
                                scanning: _linkScanning,
                                tagId: _linkTagId,
                                linking: _linking,
                                pulseAnim: _pulseAnim,
                                nameError: _linkNameError,
                                phoneError: _linkPhoneError,
                                onStartScan: _linkStartScan,
                                onCancelScan: _linkCancelScan,
                                onReset: _linkReset,
                                onLink: _linkPassenger,
                              )
                            : NfcRechargeSection(
                                key: const ValueKey('recharge'),
                                input: _rechargeInput,
                                rechargeState: _rechargeState,
                                amountCtrl: _amountCtrl,
                                phoneCtrl: _rechargePhoneCtrl,
                                passenger: _rechargePassenger,
                                recharging: _recharging,
                                pulseAnim: _pulseAnim,
                                onInputChanged: (v) {
                                  _rechargeCancel();
                                  setState(() => _rechargeInput = v);
                                },
                                onScan: _rechargeScan,
                                onCancel: _rechargeCancel,
                                onConfirm: _confirmRecharge,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(AppLocalizations l) {
    return NfcModeSelector(
      children: [
        NfcModeTab(
          label: l.nfcLinkModeTab,
          icon: Icons.link_rounded,
          active: _mode == _PageMode.link,
          activeColor: AppColors.primary,
          onTap: () {
            _rechargeCancel();
            setState(() => _mode = _PageMode.link);
          },
        ),
        NfcModeTab(
          label: l.nfcRechargeModeTab,
          icon: Icons.bolt_rounded,
          active: _mode == _PageMode.recharge,
          activeColor: AppColors.primary,
          onTap: () {
            _linkCancelScan();
            setState(() => _mode = _PageMode.recharge);
          },
        ),
      ],
    );
  }
}

// ── Balance card ───────────────────────────────────────────────────────────────

class _NfcBalanceCard extends StatelessWidget {
  final DriverEntity driver;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onTopUp;

  const _NfcBalanceCard({
    required this.driver,
    required this.onWithdraw,
    required this.onTransfer,
    required this.onTopUp,
  });

  void _showActions(BuildContext context, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BalanceActionsSheet(
        l: l,
        onWithdraw: onWithdraw,
        onTransfer: onTransfer,
        onTopUp: onTopUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = NumberFormat('#,##0.00');
    return GestureDetector(
      onTap: () => _showActions(context, l),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5A300), Color(0xFFE08000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF5A300).withValues(alpha: 0.28),
              blurRadius: 14,
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
                color: Colors.black.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.balance,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmt.format(driver.balance),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2, left: 4),
                        child: Text('MAD',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right,
                  color: Colors.black87, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Balance actions bottom sheet ───────────────────────────────────────────────

class _BalanceActionsSheet extends StatelessWidget {
  final AppLocalizations l;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onTopUp;

  const _BalanceActionsSheet({
    required this.l,
    required this.onWithdraw,
    required this.onTransfer,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _ActionTile(
            icon: Icons.north_east,
            label: l.withdraw,
            color: AppColors.red,
            onTap: () {
              Navigator.pop(context);
              onWithdraw();
            },
            c: c,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.send,
            label: l.transfer,
            color: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              onTransfer();
            },
            c: c,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.south_west,
            label: l.topUp,
            color: AppColors.teal,
            onTap: () {
              Navigator.pop(context);
              onTopUp();
            },
            c: c,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final AppColors c;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: c.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
