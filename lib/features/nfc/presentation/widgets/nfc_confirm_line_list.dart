import 'package:flutter/material.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';

class NfcConfirmLineList extends StatelessWidget {
  final List<NfcLineInfo> lines;
  final NfcLineInfo? selectedLine;
  final ValueChanged<NfcLineInfo> onLineSelected;

  const NfcConfirmLineList({
    super.key,
    required this.lines,
    required this.selectedLine,
    required this.onLineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lines
          .map((line) => NfcConfirmLineCard(
                line: line,
                isSelected: selectedLine?.id == line.id,
                onTap: () => onLineSelected(line),
              ))
          .toList(),
    );
  }
}

class NfcConfirmLineCard extends StatelessWidget {
  final NfcLineInfo line;
  final bool isSelected;
  final VoidCallback onTap;

  const NfcConfirmLineCard({
    super.key,
    required this.line,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : c.textSecondary,
                  width: 1.5,
                ),
                color:
                    isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.origin,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : c.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('→ ${line.destination}',
                            style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : c.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${line.price} MAD',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : c.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
