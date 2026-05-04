import 'package:flutter/material.dart';
import 'package:cashier/core/theme/app_theme.dart';

class NfcConfirmSeatPicker extends StatelessWidget {
  final int totalSeats;
  final int? selectedSeat;
  final ValueChanged<int> onSeatTap;

  const NfcConfirmSeatPicker({
    super.key,
    required this.totalSeats,
    required this.selectedSeat,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSeats, (i) {
        final seat = i + 1;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _SeatBtn(
            number: seat,
            isSelected: selectedSeat == seat,
            onTap: () => onSeatTap(seat),
          ),
        );
      }),
    );
  }
}

class _SeatBtn extends StatelessWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeatBtn(
      {required this.number, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal.withValues(alpha: 0.18)
              : AppColors.teal.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? AppColors.teal
                : AppColors.teal.withValues(alpha: 0.45),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
