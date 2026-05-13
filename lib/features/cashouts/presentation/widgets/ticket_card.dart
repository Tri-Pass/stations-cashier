import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';

class TicketCard extends StatelessWidget {
  final TicketEntity ticket;
  final VoidCallback? onCashout;
  final bool cashinOut;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onCashout,
    this.cashinOut = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    final bool canCashout = ticket.isCash && ticket.isUnpaid && onCashout != null;
    final bool isNfc = !ticket.isCash;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Route + amount header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ticket.line.origin} → ${ticket.line.destination}',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.airline_seat_recline_normal,
                              size: 13, color: c.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.totalSeats} ${l.seats.toLowerCase()}',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 12),
                          ),
                          if (ticket.departedAt != null) ...[
                            Text('  ·  ',
                                style: TextStyle(
                                    color: c.textSecondary, fontSize: 12)),
                            Icon(Icons.access_time,
                                size: 13, color: c.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              _formatTime(ticket.departedAt!),
                              style: TextStyle(
                                  color: c.textSecondary, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${ticket.amount.toStringAsFixed(0)} MAD',
                      style: TextStyle(
                        color: canCashout ? AppColors.primary : c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(ticket: ticket, l: l),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: c.border, height: 1),

          // ── Payment method + action ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                // Payment method pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isNfc
                        ? const Color(0xFF1565C0).withValues(alpha: 0.10)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isNfc ? Icons.nfc : Icons.payments_outlined,
                        size: 13,
                        color: isNfc
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isNfc ? l.nfc : l.cash,
                        style: TextStyle(
                          color: isNfc
                              ? const Color(0xFF1565C0)
                              : const Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Cashout button (cash + unpaid only)
                if (canCashout)
                  SizedBox(
                    height: 34,
                    child: cashinOut
                        ? const SizedBox(
                            width: 34,
                            height: 34,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: onCashout,
                            icon: const Icon(Icons.arrow_circle_up_outlined,
                                size: 15),
                            label: Text(l.cashout,
                                style: const TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                  )
                else if (isNfc)
                  Text(
                    l.nfcAutoTransferred,
                    style: TextStyle(color: c.textSecondary, fontSize: 11),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 15, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        l.paid,
                        style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
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

class _StatusBadge extends StatelessWidget {
  final TicketEntity ticket;
  final AppLocalizations l;
  const _StatusBadge({required this.ticket, required this.l});

  @override
  Widget build(BuildContext context) {
    final bool unpaidCash = ticket.isCash && ticket.isUnpaid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: unpaidCash
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        unpaidCash ? l.unpaid : l.paid,
        style: TextStyle(
          color: unpaidCash ? AppColors.primary : AppColors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
