import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/services/sunmi_nfc_service.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/usecases/link_nfc_usecase.dart';

class NfcLinkPage extends StatefulWidget {
  const NfcLinkPage({super.key});

  @override
  State<NfcLinkPage> createState() => _NfcLinkPageState();
}

class _NfcLinkPageState extends State<NfcLinkPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<Map<String, dynamic>>? _nfcSub;
  final TextEditingController _phoneCtrl = TextEditingController();

  bool _scanning = false;
  bool _nfcStarted = false;
  String? _detectedTagId;
  bool _linking = false;

  bool get _hasPhone => _phoneCtrl.text.trim().isNotEmpty;

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
    _phoneCtrl.addListener(() => setState(() {}));
  }

  void _startScan() {
    setState(() {
      _scanning = true;
      _detectedTagId = null;
    });
    _pulseCtrl.repeat(reverse: true);
    _nfcStarted = true;
    SunmiNfcService.startScanning();
    _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
      if (event['event'] == 'CARD_FOUND' && mounted) {
        _onTagDetected(event['details']?.toString() ?? '');
      }
    });
  }

  void _stopNfc() {
    if (!_nfcStarted) return;
    _nfcStarted = false;
    SunmiNfcService.stopScanning();
    _nfcSub?.cancel();
  }

  void _onTagDetected(String tagId) {
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _stopNfc();
    setState(() {
      _scanning = false;
      _detectedTagId = tagId;
    });
  }

  void _cancelScan() {
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    _stopNfc();
    setState(() => _scanning = false);
  }

  void _reset() {
    _pulseCtrl.reset();
    setState(() {
      _scanning = false;
      _detectedTagId = null;
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _phoneCtrl.dispose();
    _stopNfc();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l.nfcLinkTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Phone number input ────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.passengerToLink,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      enabled: !_scanning,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l.passengerPhoneHint,
                        hintStyle: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AppColors.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ── NFC status area ───────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _detectedTagId != null
                      ? _buildTagDetected(l)
                      : _scanning
                          ? _buildScanning(l)
                          : _buildIdle(l),
                ),
              ),
              const SizedBox(height: 16),
              // ── Action button ─────────────────────────────────────
              _buildActionButton(l),
              if (_detectedTagId != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    l.scanAnother,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ] else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Idle ──────────────────────────────────────────────────────────────────

  Widget _buildIdle(AppLocalizations l) {
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.teal.withValues(alpha: 0.35), width: 2),
          ),
          child: const Icon(Icons.nfc, color: AppColors.teal, size: 54),
        ),
        const SizedBox(height: 20),
        Text(
          l.nfcLinkDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  // ── Scanning ──────────────────────────────────────────────────────────────

  Widget _buildScanning(AppLocalizations l) {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.2),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.nfc, color: AppColors.teal, size: 60),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l.nfcScanning,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l.nfcApproachDetect,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  // ── Tag detected ──────────────────────────────────────────────────────────

  Widget _buildTagDetected(AppLocalizations l) {
    return Column(
      key: const ValueKey('detected'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.green, width: 2),
          ),
          child: const Icon(Icons.nfc, color: AppColors.green, size: 40),
        ),
        const SizedBox(height: 14),
        Text(
          l.cardDetected,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.green.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.nfcIdLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _detectedTagId ?? '',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _linkPassenger(AppLocalizations l) async {
    if (_detectedTagId == null || !_hasPhone) return;
    setState(() => _linking = true);
    try {
      await sl<LinkNfcUseCase>()(LinkNfcParams(
        phone: _phoneCtrl.text.trim(),
        nfcTagId: _detectedTagId!,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.linkSuccess),
        backgroundColor: AppColors.green,
      ));
      _reset();
      _phoneCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColors.red,
      ));
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  // ── Action button (changes per state) ─────────────────────────────────────

  Widget _buildActionButton(AppLocalizations l) {
    // Scanning → Cancel
    if (_scanning) {
      return SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _cancelScan,
          icon: const Icon(Icons.close, size: 18),
          label: Text(
            l.cancel,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    // Tag detected → Link passenger
    if (_detectedTagId != null) {
      return SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _linking ? null : () => _linkPassenger(l),
          icon: _linking
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.link, size: 20),
          label: Text(
            l.linkPassenger,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.green.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      );
    }

    // Idle → Scan NFC (disabled until phone is entered)
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _hasPhone ? _startScan : null,
        icon: const Icon(Icons.nfc, size: 22),
        label: Text(
          l.scanNfcCard,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.25),
          disabledForegroundColor: Colors.black38,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

