import 'package:flutter/material.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/widgets/compact_date_picker.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/usecases/cashout_ticket_usecase.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_driver_tickets_usecase.dart';
import 'package:cashier/features/cashouts/presentation/widgets/ticket_card.dart';

class DriverTicketsPage extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String driverPhone;

  const DriverTicketsPage({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
  });

  @override
  State<DriverTicketsPage> createState() => _DriverTicketsPageState();
}

class _DriverTicketsPageState extends State<DriverTicketsPage> {
  // 'all' | 'unpaid' | 'paid'
  String _filter = 'unpaid';

  DateTime? _selectedDate;

  DriverTicketsEntity? _data;
  bool _loading = true;
  String? _error;
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await sl<GetDriverTicketsUseCase>()(
        GetDriverTicketsParams(
          driverId: widget.driverId,
          date: _selectedDate != null ? _toApiDate(_selectedDate!) : null,
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

  String _toApiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _formatDate(AppLocalizations l, DateTime? d) {
    if (d == null) return l.allDates;
    if (_isToday(d)) return l.today;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showCompactDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    _load();
  }

  void _resetDate() {
    setState(() => _selectedDate = null);
    _load();
  }

  List<TicketEntity> get _filteredTickets {
    final all = _data?.tickets ?? [];
    return switch (_filter) {
      'unpaid' => all.where((t) => t.isCash && t.isUnpaid).toList(),
      'paid' => all.where((t) => !t.isUnpaid || !t.isCash).toList(),
      _ => all,
    };
  }

  double get _totalUnpaidCash => (_data?.tickets ?? [])
      .where((t) => t.isCash && t.isUnpaid)
      .fold(0.0, (s, t) => s + t.amount);

  int get _unpaidCashCount =>
      (_data?.tickets ?? []).where((t) => t.isCash && t.isUnpaid).length;

  Future<void> _cashoutSingle(TicketEntity ticket) async {
    final l = AppLocalizations.of(context);
    final confirmed = await _showConfirmDialog(
      title: l.confirmCashoutTitle,
      message: l.confirmCashoutMsg(ticket.amount.toStringAsFixed(0)),
    );
    if (!confirmed || !mounted) return;

    setState(() => _processingIds.add(ticket.id));
    try {
      await sl<CashoutTicketUseCase>()(
        CashoutTicketParams(
          driverId: widget.driverId,
          ticketId: ticket.id,
          all: false,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _processingIds.remove(ticket.id));
    }
  }

  Future<void> _cashoutAll() async {
    final l = AppLocalizations.of(context);
    final confirmed = await _showConfirmDialog(
      title: l.confirmCashoutTitle,
      message: l.confirmCashoutAllMsg(
          _unpaidCashCount, _totalUnpaidCash.toStringAsFixed(0)),
    );
    if (!confirmed || !mounted) return;

    setState(() => _loading = true);
    try {
      await sl<CashoutTicketUseCase>()(
        CashoutTicketParams(driverId: widget.driverId, all: true),
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cashoutSuccess),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
      );
    }
  }

  Future<bool> _showConfirmDialog(
      {required String title, required String message}) async {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: c.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            content: Text(message,
                style: TextStyle(color: c.textSecondary, fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.cancel, style: TextStyle(color: c.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(l.confirmCashout,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    final showCashoutAll = _unpaidCashCount > 0;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.driverName,
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              widget.driverPhone,
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.refresh, color: AppColors.primary, size: 18),
            ),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
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
                      _buildFilterChips(l, c),
                      const SizedBox(height: 14),
                      Text(
                        l.ticketsListLabel,
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
              SliverToBoxAdapter(
                  child: SizedBox(height: showCashoutAll ? 90 : 32)),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          showCashoutAll && !_loading ? _buildCashoutAllBar(l, c) : null,
    );
  }

  // ── Summary card ────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(AppLocalizations l, AppColors c) {
    final cashToPay = _totalUnpaidCash;
    final nfcDone = (_data?.summary.totalNfcAmount ?? 0.0);
    final totalTrips = _data?.summary.totalTickets ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
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
            l.totalCashToPay,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            _loading ? '— MAD' : '${cashToPay.toStringAsFixed(0)} MAD',
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryChip(
                icon: Icons.receipt_long_outlined,
                label: _loading ? '—' : '$totalTrips ${l.trips}',
              ),
              const SizedBox(width: 12),
              _SummaryChip(
                icon: Icons.nfc,
                label: _loading
                    ? '—'
                    : '${nfcDone.toStringAsFixed(0)} MAD ${l.nfc}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter chips ─────────────────────────────────────────────────────────────

  Widget _buildFilterChips(AppLocalizations l, AppColors c) {
    final hasDate = _selectedDate != null;
    final isToday = hasDate && _isToday(_selectedDate!);
    final dateActive = hasDate && !isToday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday
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
                          _formatDate(l, _selectedDate),
                          style: TextStyle(
                            color: isToday ? AppColors.primary : c.textPrimary,
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
            if (dateActive) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _resetDate,
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
        ),
        const SizedBox(height: 10),
        // Status chips
        Row(
          children: [
            _FilterChip(
              label: l.allTickets,
              selected: _filter == 'all',
              onTap: () => _setFilter('all'),
              c: c,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: l.unpaid,
              selected: _filter == 'unpaid',
              onTap: () => _setFilter('unpaid'),
              badge: _unpaidCashCount > 0 ? '$_unpaidCashCount' : null,
              c: c,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: l.paid,
              selected: _filter == 'paid',
              onTap: () => _setFilter('paid'),
              c: c,
            ),
          ],
        ),
      ],
    );
  }

  void _setFilter(String f) {
    if (_filter != f) setState(() => _filter = f);
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

    final items = _filteredTickets;
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
                Icon(Icons.confirmation_number_outlined,
                    color: c.textSecondary, size: 40),
                const SizedBox(height: 12),
                Text(
                  l.noTickets,
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
            child: TicketCard(
              ticket: items[i],
              cashinOut: _processingIds.contains(items[i].id),
              onCashout: items[i].isCash && items[i].isUnpaid
                  ? () => _cashoutSingle(items[i])
                  : null,
            ),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  // ── Cashout all bar ──────────────────────────────────────────────────────────

  Widget _buildCashoutAllBar(AppLocalizations l, AppColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _cashoutAll,
            icon: const Icon(Icons.arrow_circle_up_outlined, size: 20),
            label: Text(
              '${l.cashoutAll}  ·  ${_totalUnpaidCash.toStringAsFixed(0)} MAD',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;
  final AppColors c;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.c,
    this.badge,
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
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : c.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
