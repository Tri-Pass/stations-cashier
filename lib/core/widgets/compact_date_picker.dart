import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';

/// Opens a compact bottom-sheet date picker.
/// Returns the selected [DateTime] or null if cancelled.
Future<DateTime?> showCompactDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  final l = AppLocalizations.of(context);
  final c = AppColors.of(context);
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CompactDatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: lastDate ?? now,
      l: l,
      c: c,
    ),
  );
}

class CompactDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final AppLocalizations l;
  final AppColors c;

  const CompactDatePickerSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.l,
    required this.c,
  });

  @override
  State<CompactDatePickerSheet> createState() => _CompactDatePickerSheetState();
}

class _CompactDatePickerSheetState extends State<CompactDatePickerSheet> {
  late DateTime _selected;
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  bool get _canGoPrev {
    final prev = DateTime(_viewMonth.year, _viewMonth.month - 1);
    return !prev.isBefore(
        DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  bool get _canGoNext {
    final next = DateTime(_viewMonth.year, _viewMonth.month + 1);
    return !next
        .isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  bool _isSelected(int day) =>
      _selected.year == _viewMonth.year &&
      _selected.month == _viewMonth.month &&
      _selected.day == day;

  bool _isTodayCell(int day) {
    final now = DateTime.now();
    return now.year == _viewMonth.year &&
        now.month == _viewMonth.month &&
        now.day == day;
  }

  bool _isDisabled(int day) {
    final date = DateTime(_viewMonth.year, _viewMonth.month, day);
    final first = DateTime(
        widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final last = DateTime(
        widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    return date.isBefore(first) || date.isAfter(last);
  }

  Widget _buildGrid(AppColors c) {
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final startOffset = _viewMonth.weekday - 1;

    final cells = <Widget>[
      for (int i = 0; i < startOffset; i++) const SizedBox(),
      for (int day = 1; day <= daysInMonth; day++)
        DatePickerDayCell(
          day: day,
          selected: _isSelected(day),
          isToday: _isTodayCell(day),
          disabled: _isDisabled(day),
          onTap: _isDisabled(day)
              ? null
              : () => setState(() =>
                  _selected = DateTime(_viewMonth.year, _viewMonth.month, day)),
          c: c,
        ),
    ];

    while (cells.length % 7 != 0) {
      cells.add(const SizedBox());
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Row(
        children: cells
            .sublist(i, i + 7)
            .map((cell) => Expanded(child: cell))
            .toList(),
      ));
      if (i + 7 < cells.length) rows.add(const SizedBox(height: 2));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final c = widget.c;
    final locale = l.isAr ? 'ar' : 'fr';
    final monthLabel = DateFormat('MMMM yyyy', locale).format(_viewMonth);
    final dayNames = l.isAr
        ? ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح']
        : ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Month navigation
          Row(
            children: [
              DatePickerNavButton(
                icon: Icons.chevron_left,
                enabled: _canGoPrev,
                onTap: () => setState(() => _viewMonth =
                    DateTime(_viewMonth.year, _viewMonth.month - 1)),
                c: c,
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DatePickerNavButton(
                icon: Icons.chevron_right,
                enabled: _canGoNext,
                onTap: () => setState(() => _viewMonth =
                    DateTime(_viewMonth.year, _viewMonth.month + 1)),
                c: c,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekday headers
          Row(
            children: dayNames
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          _buildGrid(c),
          const SizedBox(height: 16),
          // Cancel / OK
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textSecondary,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l.ok,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Day cell ─────────────────────────────────────────────────────────────────

class DatePickerDayCell extends StatelessWidget {
  final int day;
  final bool selected;
  final bool isToday;
  final bool disabled;
  final VoidCallback? onTap;
  final AppColors c;

  const DatePickerDayCell({
    super.key,
    required this.day,
    required this.selected,
    required this.isToday,
    required this.disabled,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Decoration? decoration;

    if (selected) {
      decoration = const BoxDecoration(
          color: AppColors.primary, shape: BoxShape.circle);
      textColor = Colors.white;
    } else if (isToday) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
      );
      textColor = AppColors.primary;
    } else if (disabled) {
      decoration = null;
      textColor = c.textSecondary.withValues(alpha: 0.35);
    } else {
      decoration = null;
      textColor = c.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 38,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: decoration,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight:
                    selected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav button ───────────────────────────────────────────────────────────────

class DatePickerNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final AppColors c;

  const DatePickerNavButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? c.iconBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled
              ? c.textPrimary
              : c.textSecondary.withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }
}
