import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/widgets/compact_date_picker.dart';
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
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _paymentMethod;

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
          dateFrom: _dateFrom != null ? _toApiDate(_dateFrom!) : null,
          dateTo: _dateTo != null ? _toApiDate(_dateTo!) : null,
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
    final initial = isFrom ? (_dateFrom ?? now) : (_dateTo ?? now);
    final picked = await showCompactDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
        if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
          _dateTo = _dateFrom;
        }
      } else {
        _dateTo = picked;
        if (_dateFrom != null && _dateFrom!.isAfter(_dateTo!)) {
          _dateFrom = _dateTo;
        }
      }
    });
    _load();
  }

  void _resetDateFilter() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _load();
  }

  bool get _isDefaultDateRange => _dateFrom == null && _dateTo == null;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get _isSameDay =>
      _dateFrom != null &&
      _dateTo != null &&
      _dateFrom!.year == _dateTo!.year &&
      _dateFrom!.month == _dateTo!.month &&
      _dateFrom!.day == _dateTo!.day;

  String _formatDate(AppLocalizations l, DateTime? d) {
    if (d == null) return l.allDates;
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _hasAdvancedFilters
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.of(context).iconBg,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: _hasAdvancedFilters
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            tooltip: l.filtersLabel,
            onPressed: _showAdvancedFilters,
          ),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.of(context).iconBg,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child:
                  const Icon(Icons.refresh, color: AppColors.primary, size: 18),
            ),
            tooltip: l.retry,
            onPressed: _load,
          ),
          const SizedBox(width: 4),
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
                      _buildSummaryCard(l, c),
                      const SizedBox(height: 14),
                      _buildDateRange(l, c),
                      const SizedBox(height: 10),
                      _buildPaymentMethodFilter(l, c),
                      const SizedBox(height: 14),
                      Text(
                        l.cashoutsListLabel,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // ── Summary card (matches driver tickets page gradient style) ────────────────

  Widget _buildSummaryCard(AppLocalizations l, AppColors c) {
    final stats = _data?.stats;
    final totalRemaining = stats?.totalRemaining ?? 0.0;
    final totalTickets = stats?.totalTickets ?? 0;
    final totalCollected = stats?.totalCollected ?? 0.0;
    final totalPayouts = stats?.totalPayouts ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5A300), Color(0xFFE08000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5A300).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: label + trips badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l.totalCashouts,
                  style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        color: Colors.black54, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _loading ? '—' : '$totalTickets ${l.trips}',
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Big amount
          Text(
            _loading ? '— MAD' : '${totalRemaining.toStringAsFixed(0)} MAD',
            style: const TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          // Bottom: collected + paid chips
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  icon: Icons.account_balance_wallet_outlined,
                  value: _loading
                      ? '—'
                      : '${totalCollected.toStringAsFixed(0)} MAD',
                  label: l.statsTotalCollected,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryChip(
                  icon: Icons.check_circle_outline,
                  value:
                      _loading ? '—' : '${totalPayouts.toStringAsFixed(0)} MAD',
                  label: l.statsTotalPayouts,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Date range ───────────────────────────────────────────────────────────────

  Widget _buildDateRange(AppLocalizations l, AppColors c) {
    final hasDate = !_isDefaultDateRange;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(isFrom: true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _dateFrom != null && _isToday(_dateFrom!)
                    ? AppColors.primary.withValues(alpha: 0.07)
                    : c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _dateFrom != null && _isToday(_dateFrom!)
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : c.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(l, _dateFrom),
                      style: TextStyle(
                        color: _dateFrom != null && _isToday(_dateFrom!)
                            ? AppColors.primary
                            : c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more, color: c.textSecondary, size: 16),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 16, color: c.textSecondary),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(isFrom: false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _dateTo != null && _isToday(_dateTo!)
                    ? AppColors.primary.withValues(alpha: 0.07)
                    : c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _dateTo != null && _isToday(_dateTo!)
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : c.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSameDay && _dateTo != null && _isToday(_dateTo!)
                          ? l.today
                          : _formatDate(l, _dateTo),
                      style: TextStyle(
                        color: _dateTo != null && _isToday(_dateTo!)
                            ? AppColors.primary
                            : c.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more, color: c.textSecondary, size: 16),
                ],
              ),
            ),
          ),
        ),
        if (hasDate) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _resetDateFilter,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.close, color: c.textSecondary, size: 16),
            ),
          ),
        ],
      ],
    );
  }

  // ── Payment method filter (same _FilterChip as driver tickets) ───────────────

  Widget _buildPaymentMethodFilter(AppLocalizations l, AppColors c) {
    return Row(
      children: [
        _FilterChip(
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
        _FilterChip(
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
        _FilterChip(
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

  // ── List ─────────────────────────────────────────────────────────────────────

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
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
            child: CashoutCard(
              cashout: items[i],
              filter: _paymentMethod,
              onTap: () => context.push('/driver-tickets', extra: {
                'driverId': items[i].driver.id,
                'driverName': items[i].driver.name,
                'driverPhone': items[i].driver.phone,
              }),
            ),
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    height: 1.2,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  final AppColors c;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.c,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary.withValues(alpha: 0.15) : c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.primary : c.textSecondary,
              ),
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

// ─── Advanced filter bottom sheet ─────────────────────────────────────────────

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
                    style: const TextStyle(color: AppColors.red, fontSize: 13)),
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
