import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/usecases/get_lines_usecase.dart';
import 'package:cashier/features/lines/domain/usecases/get_line_queue_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/get_passenger_by_nfc_usecase.dart';
import 'package:cashier/core/services/cashier_printer.dart';
import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_balance_card.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_trips_section.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_seat_picker.dart';
import 'package:cashier/features/nfc/presentation/widgets/nfc_confirm_line_list.dart';

class NfcConfirmPage extends StatefulWidget {
  final String nfcTagId;
  const NfcConfirmPage({super.key, required this.nfcTagId});

  @override
  State<NfcConfirmPage> createState() => _NfcConfirmPageState();
}

class _NfcConfirmPageState extends State<NfcConfirmPage> {
  NfcClientInfo? _client;
  List<NfcLineInfo> _availableLines = [];
  bool _loading = true;
  String? _loadError;
  bool _adding = false;
  NfcLineInfo? _selectedLine;
  int? _selectedSeat;
  String? _resolvedTaxiId;
  List<QueueTaxiEntity> _taxiQueue = [];
  bool _tripsExpanded = false;

  static const int _totalSeats = 6;

  String? get _stationId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.driver.station?.id : null;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final stationId = _stationId;
    try {
      final passengerFuture = sl<GetPassengerByNfcUseCase>()(widget.nfcTagId);
      final linesFuture = stationId != null
          ? sl<GetLinesUseCase>()(stationId)
          : Future.value([]);

      final passenger = await passengerFuture;
      final linesRaw = await linesFuture;

      if (!mounted) return;
      setState(() {
        _client = NfcClientInfo(
          id: passenger.id,
          name: passenger.name,
          phone: passenger.phone,
          balance: passenger.balance,
          trips: passenger.recentTrips
              .map((t) => NfcTripInfo(from: t.from, to: t.to))
              .toList(),
        );
        _availableLines = linesRaw
            .map((e) => NfcLineInfo(
                  id: e.id,
                  origin: e.origin,
                  destination: e.destination,
                  price: e.price.toInt(),
                ))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  // ── Queue resolution ─────────────────────────────────────────────────────

  Future<void> _resolveFirstTaxi(String lineId) async {
    final stationId = _stationId;
    if (stationId == null) return;
    try {
      final queue = await sl<GetLineQueueUseCase>()(stationId, lineId);
      if (!mounted) return;
      final first = queue.isEmpty
          ? null
          : queue.firstWhere((t) => t.isFirst, orElse: () => queue.first);
      setState(() {
        _taxiQueue = queue;
        _resolvedTaxiId = first?.id;
      });
    } catch (_) {}
  }

  // ── Seat validation dialog ───────────────────────────────────────────────

  Future<bool> _showSeatValidationDialog(
      int available, {required bool hasNext}) async {
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.seatValidationTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          hasNext
              ? l.seatValidationHasNext(available)
              : l.seatValidationNoNext(available),
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          if (hasNext)
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(l.nextTaxi,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
    return result == true;
  }

  // ── Booking ──────────────────────────────────────────────────────────────

  Future<void> _addToQueue() async {
    if (_client == null || _selectedLine == null || _selectedSeat == null) {
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final taxiId = _resolvedTaxiId;
    if (taxiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).noTaxiForLine),
        backgroundColor: AppColors.red,
      ));
      return;
    }

    final currentIndex = _taxiQueue.indexWhere((t) => t.id == taxiId);
    if (currentIndex >= 0) {
      final current = _taxiQueue[currentIndex];
      if (_selectedSeat! > current.availableSeats) {
        final hasNext = currentIndex + 1 < _taxiQueue.length;
        final confirmed = await _showSeatValidationDialog(
            current.availableSeats,
            hasNext: hasNext);
        if (!mounted || !confirmed) return;
        setState(() => _resolvedTaxiId = _taxiQueue[currentIndex + 1].id);
        return _addToQueue();
      }
    }

    setState(() => _adding = true);
    try {
      final result = await sl<CreateBookingUseCase>()(CreateBookingParams(
        taxiId: _resolvedTaxiId!,
        lineId: _selectedLine!.id,
        seatCount: _selectedSeat!,
        paymentMethod: 'nfc',
        cashierId: authState.driver.id,
        nfcTagId: widget.nfcTagId,
      ));

      final ticket = result.ticket;
      if (ticket != null) {
        await CashierPrinter.printTicket(
          ticket: ticket.copyWith(seatNumber: _selectedSeat!),
          stationName: authState.driver.station?.name ?? '',
        );
      }

      if (mounted) {
        sl<BookingRefreshNotifier>().refresh();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _adding = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          l.nfcDetected,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _loadError != null
                ? _buildError(l)
                : _buildContent(l),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    final isResolving =
        _selectedLine != null && _resolvedTaxiId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NfcConfirmBalanceCard(client: _client!),
                const SizedBox(height: 16),
                NfcConfirmTripsSection(
                  client: _client!,
                  expanded: _tripsExpanded,
                  onToggle: () =>
                      setState(() => _tripsExpanded = !_tripsExpanded),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(l.seats,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600)),
                ),
                NfcConfirmSeatPicker(
                  totalSeats: _totalSeats,
                  selectedSeat: _selectedSeat,
                  onSeatTap: (seat) {
                    setState(() {
                      _selectedSeat = seat;
                      if (_selectedLine != null) {
                        _resolvedTaxiId = null;
                        _taxiQueue = [];
                      }
                    });
                    if (_selectedLine != null) {
                      _resolveFirstTaxi(_selectedLine!.id);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(l.selectLine,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600)),
                ),
                NfcConfirmLineList(
                  lines: _availableLines,
                  selectedLine: _selectedLine,
                  onLineSelected: (line) {
                    setState(() {
                      _selectedLine = line;
                      _resolvedTaxiId = null;
                      _taxiQueue = [];
                    });
                    _resolveFirstTaxi(line.id);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomCta(l, isResolving),
      ],
    );
  }

  Widget _buildBottomCta(AppLocalizations l, bool isResolving) {
    final disabled =
        _adding || isResolving || _selectedLine == null || _selectedSeat == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: disabled ? null : _addToQueue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: (_adding || isResolving)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text(l.addSeat,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(l.cancel,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _loadError ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _loadError = null;
                });
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(l.retry),
            ),
          ],
        ),
      ),
    );
  }
}
