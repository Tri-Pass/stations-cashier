import 'package:flutter/material.dart';
import 'package:cashier/core/theme/app_theme.dart';

class SeatButton extends StatelessWidget {
  final int number;
  final bool isDisabled;
  final VoidCallback? onTap;

  const SeatButton({super.key, required this.number, required this.isDisabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final Color bg;
    final Color border;
    final Color text;

    if (isDisabled) {
      bg = c.iconBg;
      border = c.border;
      text = c.textSecondary.withValues(alpha: 0.5);
    } else {
      bg = AppColors.teal.withValues(alpha: 0.08);
      border = AppColors.teal.withValues(alpha: 0.45);
      text = AppColors.teal;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
