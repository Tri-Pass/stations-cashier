import 'package:flutter/material.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';

class LineCard extends StatelessWidget {
  final LineInfo line;
  final bool selected;
  final VoidCallback onTap;

  const LineCard({super.key, required this.line, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.near_me,
                    color: selected ? AppColors.primary : AppColors.textSecondary, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    line.destination,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${line.price} DH',
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: line.taxiCount > 0
                        ? AppColors.teal.withValues(alpha: 0.12)
                        : AppColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${line.taxiCount}',
                    style: TextStyle(
                      color: line.taxiCount > 0 ? AppColors.teal : AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
