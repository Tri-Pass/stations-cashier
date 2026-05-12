import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';

class CashoutCard extends StatelessWidget {
  final CashoutSummaryEntity cashout;
  // null = show both, 'cash' = cash only, 'nfc' = nfc only
  final String? filter;

  const CashoutCard({super.key, required this.cashout, this.filter});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    final hasRoute =
        cashout.line.origin.isNotEmpty || cashout.line.destination.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_taxi,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cashout.driver.name,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        cashout.driver.phone,
                        style: TextStyle(color: c.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${cashout.totalAmount.toStringAsFixed(0)} MAD',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cashout.totalSeats} ${l.seats.toLowerCase()}',
                      style: TextStyle(color: c.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: c.border, height: 1),

          // ── Payment breakdown ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                if (filter != 'nfc') ...[
                  Expanded(
                    child: _AmountTile(
                      icon: Icons.payments_outlined,
                      label: l.cash,
                      amount: cashout.cashAmount,
                      color: const Color(0xFF2E7D32),
                      bgColor: const Color(0xFF2E7D32).withValues(alpha: 0.10),
                      c: c,
                    ),
                  ),
                ],
                if (filter == null) const SizedBox(width: 8),
                if (filter != 'cash') ...[
                  Expanded(
                    child: _AmountTile(
                      icon: Icons.nfc,
                      label: l.nfc,
                      amount: cashout.nfcAmount,
                      color: const Color(0xFF1565C0),
                      bgColor: const Color(0xFF1565C0).withValues(alpha: 0.10),
                      c: c,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Footer: plate · route · time ───────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            decoration: BoxDecoration(
              color: c.background.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14)),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                _Tag(
                  icon: Icons.confirmation_number_outlined,
                  label: cashout.taxi.plateNumber,
                  c: c,
                ),
                if (hasRoute)
                  _Tag(
                    icon: Icons.route_outlined,
                    label: cashout.line.destination.isEmpty
                        ? cashout.line.origin
                        : '${cashout.line.origin} → ${cashout.line.destination}',
                    c: c,
                  ),
                if (cashout.departedAt != null)
                  _Tag(
                    icon: Icons.access_time,
                    label: _formatTime(cashout.departedAt!),
                    c: c,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AmountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final AppColors c;

  const _AmountTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(0)} MAD',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors c;

  const _Tag({required this.icon, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: c.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
