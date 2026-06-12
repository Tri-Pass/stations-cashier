import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';

class CashoutCard extends StatelessWidget {
  final CashoutSummaryEntity cashout;
  final String? filter;
  final VoidCallback? onTap;

  const CashoutCard(
      {super.key, required this.cashout, this.filter, this.onTap});

  String get _initials {
    final parts = cashout.driver.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    final hasRemaining = cashout.remaining > 0;
    final hasRoute =
        cashout.line.origin.isNotEmpty || cashout.line.destination.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: avatar | name + phone | remaining + badge ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Initials avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + phone + route
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
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number_outlined,
                                size: 13, color: c.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${cashout.totalSeats} ${l.trips}',
                              style: TextStyle(
                                  color: c.textSecondary, fontSize: 12),
                            ),
                            if (cashout.taxi.plateNumber.isNotEmpty) ...[
                              Text('  ·  ',
                                  style: TextStyle(
                                      color: c.textSecondary, fontSize: 12)),
                              Icon(Icons.local_taxi_outlined,
                                  size: 13, color: c.textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                cashout.taxi.plateNumber,
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        if (hasRoute)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.route_outlined,
                                    size: 13, color: c.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    cashout.line.destination.isEmpty
                                        ? cashout.line.origin
                                        : '${cashout.line.origin} → ${cashout.line.destination}',
                                    style: TextStyle(
                                        color: c.textSecondary, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Remaining amount + status badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${cashout.remaining.toStringAsFixed(0)} MAD',
                        style: TextStyle(
                          color: hasRemaining
                              ? AppColors.primary
                              : c.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusBadge(hasRemaining: hasRemaining, l: l),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: c.border, height: 1),

            // ── Footer: collected | cash | nfc chips + arrow ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label: '${cashout.totalAmount.toStringAsFixed(0)} MAD',
                    color: AppColors.primary,
                  ),
                  if (filter != 'nfc') ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.payments_outlined,
                      label: cashout.cashAmount.toStringAsFixed(0),
                      color: const Color(0xFF2E7D32),
                    ),
                  ],
                  if (filter != 'cash') ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.nfc,
                      label: cashout.nfcAmount.toStringAsFixed(0),
                      color: const Color(0xFF1565C0),
                    ),
                  ],
                  const Spacer(),
                  if (cashout.totalPaid > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${cashout.totalPaid.toStringAsFixed(0)} MAD',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool hasRemaining;
  final AppLocalizations l;

  const _StatusBadge({required this.hasRemaining, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hasRemaining
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hasRemaining ? l.unpaid : l.paid,
        style: TextStyle(
          color: hasRemaining ? AppColors.primary : AppColors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
