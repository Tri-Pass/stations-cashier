import 'package:flutter/material.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_cashouts_summary_usecase.dart';
import 'package:cashier/features/cashouts/presentation/widgets/cashout_card.dart';

class CashoutsPage extends StatefulWidget {
  const CashoutsPage({super.key});

  @override
  State<CashoutsPage> createState() => _CashoutsPageState();
}

class _CashoutsPageState extends State<CashoutsPage> {
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();

  // null = all methods
  String? _paymentMethod;

  // Advanced filter fields
  final _taxiCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _lineCtrl = TextEditingController();

  CashoutsResponseEntity? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _taxiCtrl.dispose();
    _driverNameCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await sl<GetCashoutsSummaryUseCase>()(
        CashoutSummaryParams(
          dateFrom: _toApiDate(_dateFrom),
          dateTo: _toApiDate(_dateTo),
          paymentMethod: _paymentMethod,
          taxi: _taxiCtrl.text.trim().isEmpty ? null : _taxiCtrl.text.trim(),
          driverName: _driverNameCtrl.text.trim().isEmpty
              ? null
              : _driverNameCtrl.text.trim(),
          line: _lineCtrl.text.trim().isEmpty ? null : _lineCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? _dateFrom : _dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
        if (_dateTo.isBefore(_dateFrom)) _dateTo = _dateFrom;
      } else {
        _dateTo = picked;
        if (_dateFrom.isAfter(_dateTo)) _dateFrom = _dateTo;
      }
    });
    _load();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get _isSameDay =>
      _dateFrom.year == _dateTo.year &&
      _dateFrom.month == _dateTo.month &&
      _dateFrom.day == _dateTo.day;

  String _formatDate(AppLocalizations l, DateTime d) {
    if (_isToday(d)) return l.today;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  bool get _hasAdvancedFilters =>
      _taxiCtrl.text.trim().isNotEmpty ||
      _driverNameCtrl.text.trim().isNotEmpty ||
      _lineCtrl.text.trim().isNotEmpty;

  void _showAdvancedFilters() {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AdvancedFilterSheet(
        taxiCtrl: _taxiCtrl,
        driverNameCtrl: _driverNameCtrl,
        lineCtrl: _lineCtrl,
        onApply: () {
          Navigator.of(context).pop();
          _load();
        },
        onClear: () {
          _taxiCtrl.clear();
          _driverNameCtrl.clear();
          _lineCtrl.clear();
          Navigator.of(context).pop();
          _load();
        },
        l: l,
        c: c,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l.cashoutsTitle,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasAdvancedFilters
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.of(context).iconBg,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: _hasAdvancedFilters
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: Icon(
                Icons.tune,
                color: _hasAdvancedFilters
                    ? AppColors.primary
                    : AppColors.primary,
                size: 20,
              ),
            ),
            tooltip: l.filtersLabel,
            onPressed: _showAdvancedFilters,
          ),
          IconButton(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.of(context).iconBg,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
            ),
            tooltip: l.retry,
            onPressed: _load,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          backgroundColor: c.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateRange(l, c),
                      const SizedBox(height: 10),
                      _buildPaymentMethodFilter(l, c),
                      const SizedBox(height: 12),
                      _buildSummaryCard(l, c),
                      const SizedBox(height: 16),
                      _buildSectionLabel(l.cashoutsListLabel, c),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              _buildList(l, c),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRange(AppLocalizations l, AppColors c) {
    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: l.dateFrom,
            value: _formatDate(l, _dateFrom),
            onTap: () => _pickDate(isFrom: true),
            c: c,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward,
              size: 16, color: c.textSecondary),
        ),
        Expanded(
          child: _DateChip(
            label: l.dateTo,
            value: _isSameDay && _isToday(_dateTo)
                ? l.today
                : _formatDate(l, _dateTo),
            onTap: () => _pickDate(isFrom: false),
            c: c,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(AppLocalizations l, AppColors c) {
    return Row(
      children: [
        _MethodChip(
          label: l.allMethods,
          selected: _paymentMethod == null,
          onTap: () {
            if (_paymentMethod != null) {
              setState(() => _paymentMethod = null);
              _load();
            }
          },
          c: c,
        ),
        const SizedBox(width: 8),
        _MethodChip(
          label: l.cash,
          selected: _paymentMethod == 'cash',
          icon: Icons.payments_outlined,
          onTap: () {
            if (_paymentMethod != 'cash') {
              setState(() => _paymentMethod = 'cash');
              _load();
            }
          },
          c: c,
        ),
        const SizedBox(width: 8),
        _MethodChip(
          label: l.nfc,
          selected: _paymentMethod == 'nfc',
          icon: Icons.nfc,
          onTap: () {
            if (_paymentMethod != 'nfc') {
              setState(() => _paymentMethod = 'nfc');
              _load();
            }
          },
          c: c,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(AppLocalizations l, AppColors c) {
    final total = _data?.totalAmount ?? 0.0;
    final tripsCount = _data?.cashouts.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.totalCashouts,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _loading ? '— MAD' : '${total.toStringAsFixed(0)} MAD',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.local_taxi, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _loading ? '—' : '$tripsCount ${l.trips}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, AppColors c) {
    return Text(
      text,
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildList(AppLocalizations l, AppColors c) {
    if (_loading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          ),
        ),
      );
    }
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: c.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(l.retry,
                      style: TextStyle(color: c.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final items = _data?.cashouts ?? [];
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    color: c.textSecondary, size: 40),
                const SizedBox(height: 12),
                Text(
                  l.noPayments,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CashoutCard(cashout: items[i]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final AppColors c;

  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: AppColors.primary, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(value,
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  final AppColors c;

  const _MethodChip({
    required this.label,
    required this.selected,
    this.icon,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected ? AppColors.primary : c.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : c.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Advanced filter bottom sheet ────────────────────────────────────────────

class _AdvancedFilterSheet extends StatelessWidget {
  final TextEditingController taxiCtrl;
  final TextEditingController driverNameCtrl;
  final TextEditingController lineCtrl;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final AppLocalizations l;
  final AppColors c;

  const _AdvancedFilterSheet({
    required this.taxiCtrl,
    required this.driverNameCtrl,
    required this.lineCtrl,
    required this.onApply,
    required this.onClear,
    required this.l,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l.filtersLabel,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: Text(l.clearFilters,
                    style: const TextStyle(
                        color: AppColors.red, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FilterField(
            controller: taxiCtrl,
            hint: l.filterTaxi,
            icon: Icons.local_taxi_outlined,
            c: c,
          ),
          const SizedBox(height: 10),
          _FilterField(
            controller: driverNameCtrl,
            hint: l.filterDriverName,
            icon: Icons.person_outline,
            c: c,
          ),
          const SizedBox(height: 10),
          _FilterField(
            controller: lineCtrl,
            hint: l.filterLine,
            icon: Icons.route_outlined,
            c: c,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(l.applyFilters,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final AppColors c;

  const _FilterField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: c.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: c.textSecondary, size: 18),
        filled: true,
        fillColor: c.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
