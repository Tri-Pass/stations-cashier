import 'package:flutter/material.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:cashier/features/booking/presentation/widgets/seat_button.dart';

class TaxiCard extends StatelessWidget {
  final TaxiInfo taxi;
  final int available;
  final ValueChanged<int> onSeatCount;

  const TaxiCard({super.key, required this.taxi, required this.available, required this.onSeatCount});

  bool get _isFull => available <= 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Opacity(
      opacity: _isFull ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        taxi.plateNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (taxi.isFirst) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l.firstBadge,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(taxi.driver.name,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(taxi.driver.phone,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isFull
                          ? AppColors.red.withValues(alpha: 0.12)
                          : AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFull
                            ? AppColors.red.withValues(alpha: 0.4)
                            : AppColors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _isFull ? l.full : l.freeSeats(available),
                      style: TextStyle(
                        color: _isFull ? AppColors.red : AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.end,
                children: List.generate(taxi.totalSeats, (i) {
                  final count = i + 1;
                  final isDisabled = count > available;
                  return SeatButton(
                    number: count,
                    isDisabled: isDisabled,
                    onTap: isDisabled ? null : () => onSeatCount(count),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
