import 'package:flutter/material.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_cashouts_summary_usecase.dart';

class TaxiFullPaymentDialog extends StatefulWidget {
  final TaxiInfo taxi;
  final int pricePerSeat;
  final String lineOrigin;
  final String lineDestination;

  const TaxiFullPaymentDialog({
    super.key,
    required this.taxi,
    required this.pricePerSeat,
    required this.lineOrigin,
    required this.lineDestination,
  });

  @override
  State<TaxiFullPaymentDialog> createState() => _TaxiFullPaymentDialogState();
}

class _TaxiFullPaymentDialogState extends State<TaxiFullPaymentDialog> {
  CashoutSummaryEntity? _cashout;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchCashout();
  }

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchCashout() async {
    try {
      final response = await sl<GetCashoutsSummaryUseCase>()(
        CashoutSummaryParams(
          dateFrom: _today(),
          dateTo: _today(),
          taxi: widget.taxi.plateNumber,
        ),
      );
      if (!mounted) return;
      setState(() {
        _cashout =
            response.cashouts.isNotEmpty ? response.cashouts.first : null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    // Derive seat counts from amounts ÷ price (API returns amounts, not counts)
    final int? cashSeats = _cashout == null
        ? null
        : widget.pricePerSeat > 0
            ? (_cashout!.cashAmount / widget.pricePerSeat).round()
            : _cashout!.cashSeats;
    final int? nfcSeats = _cashout == null
        ? null
        : widget.pricePerSeat > 0
            ? (_cashout!.nfcAmount / widget.pricePerSeat).round()
            : _cashout!.nfcSeats;
    final double? cashAmount = _cashout?.cashAmount;
    final double? nfcAmount = _cashout?.nfcAmount;

    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.local_taxi,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              l.taxiFullTitle,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.taxiFullSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Static info (always visible immediately) ────────────
                  _InfoRow(label: l.driverLabel, value: widget.taxi.driver.name, c: c),
                  const SizedBox(height: 8),
                  _InfoRow(label: l.taxiNumberLabel, value: widget.taxi.plateNumber, c: c),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: l.destination,
                    value: '${widget.lineOrigin} → ${widget.lineDestination}',
                    c: c,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 12),

                  // ── Cash seats ──────────────────────────────────────────
                  _InfoRow(
                    label: l.cashSeatsLabel,
                    value: _loading
                        ? null
                        : '${cashSeats ?? '—'} × ${widget.pricePerSeat} MAD',
                    c: c,
                  ),
                  const SizedBox(height: 8),

                  // ── NFC seats ───────────────────────────────────────────
                  _InfoRow(
                    label: l.nfcSeatsLabel,
                    value: _loading
                        ? null
                        : '${nfcSeats ?? '—'} ${l.seats.toLowerCase()}',
                    c: c,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 12),

                  // ── NFC amount (already collected electronically) ────────
                  _InfoRow(
                    label: l.nfc,
                    value: _loading
                        ? null
                        : '${(nfcAmount ?? 0).toStringAsFixed(0)} MAD',
                    c: c,
                  ),
                  const SizedBox(height: 8),

                  // ── Cash amount to pay to driver ─────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          l.amountToPay,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2),
                            )
                          : Text(
                              '${(cashAmount ?? 0).toStringAsFixed(0)} MAD',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                  if (_error) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.cashoutLoadError,
                      style: TextStyle(color: AppColors.red, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l.ok,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// value == null  →  small inline spinner (still loading)
// value == String →  show text, wraps naturally, no ellipsis
class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final AppColors c;

  const _InfoRow({required this.label, required this.c, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        value == null
            ? const Padding(
                padding: EdgeInsets.only(top: 2),
                child: SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              )
            : Expanded(
                child: Text(
                  value!,
                  textAlign: TextAlign.end,
                  // No overflow — text wraps to next line if needed
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    );
  }
}
