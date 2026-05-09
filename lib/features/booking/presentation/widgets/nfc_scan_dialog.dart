import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/services/sunmi_nfc_service.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';

class NfcScanDialog extends StatefulWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;
  final Future<BookingResultEntity?> Function(String tagId) onBooking;
  final ValueChanged<BookingResultEntity> onBooked;
  final VoidCallback onCancel;

  const NfcScanDialog({
    super.key,
    required this.line,
    required this.taxi,
    required this.seatCount,
    required this.onBooking,
    required this.onBooked,
    required this.onCancel,
  });

  @override
  State<NfcScanDialog> createState() => _NfcScanDialogState();
}

class _NfcScanDialogState extends State<NfcScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<Map<String, dynamic>>? _nfcSub;

  bool _scanning = true;
  bool _processing = false;
  String? _errorMessage;

  int get _total => widget.seatCount * widget.line.price;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    SunmiNfcService.localHandlerActive = true;
    SunmiNfcService.startScanning();
    _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
      if (event['event'] == 'CARD_FOUND' && _scanning && !_processing && mounted) {
        _onCardDetected(event['details']?.toString() ?? '');
      }
    });
  }

  Future<void> _onCardDetected(String tagId) async {
    if (!mounted || !_scanning || _processing) return;
    _pulseCtrl.stop();
    setState(() {
      _scanning = false;
      _processing = true;
      _errorMessage = null;
    });

    final result = await widget.onBooking(tagId);

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pop();
      widget.onBooked(result);
    } else {
      setState(() {
        _processing = false;
        _scanning = true;
        _errorMessage = AppLocalizations.of(context).nfcBookingFailed;
      });
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _nfcSub?.cancel();
    SunmiNfcService.stopScanning();
    SunmiNfcService.localHandlerActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    final Widget iconWidget = _processing
        ? const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
          )
        : ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _errorMessage != null
                    ? AppColors.red.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _errorMessage != null ? AppColors.red : AppColors.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_errorMessage != null ? AppColors.red : AppColors.primary)
                        .withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                _errorMessage != null ? Icons.error_outline : Icons.nfc,
                color: _errorMessage != null ? AppColors.red : AppColors.primary,
                size: 50,
              ),
            ),
          );

    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 20),
            Text(
              _processing
                  ? l.nfcProcessing
                  : _errorMessage != null
                      ? l.nfcError
                      : l.nfcReading,
              style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.seatCount} ${l.seats}  ·  $_total DH',
              style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? l.nfcApproach,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _errorMessage != null ? AppColors.red : c.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (!_processing)
              TextButton(
                onPressed: widget.onCancel,
                child: Text(l.cancel, style: TextStyle(color: c.textSecondary)),
              ),
          ],
        ),
      ),
    );
  }
}
