import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/network/socket_service.dart';
import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:cashier/core/services/cashier_printer.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:cashier/features/lines/domain/usecases/get_lines_usecase.dart';
import 'package:cashier/features/lines/domain/usecases/get_line_queue_usecase.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/features/booking/presentation/viewmodels/booking_viewmodels.dart';
import 'package:cashier/features/booking/presentation/widgets/line_card.dart';
import 'package:cashier/features/booking/presentation/widgets/payment_button.dart';
import 'package:cashier/features/booking/presentation/widgets/taxi_card.dart';
import 'package:cashier/core/widgets/app_notification.dart';
import 'package:cashier/features/booking/presentation/widgets/success_dialog.dart';
import 'package:cashier/features/booking/presentation/widgets/nfc_scan_dialog.dart';

// ─── Main Booking Page ────────────────────────────────────────────────────────

class CashierBookingPage extends StatefulWidget {
  const CashierBookingPage({super.key});

  @override
  State<CashierBookingPage> createState() => _CashierBookingPageState();
}

class _CashierBookingPageState extends State<CashierBookingPage> {
  LineInfo? _selectedLine;
  String _paymentMethod = 'cash';

  List<LineInfo> _lines = [];
  bool _linesLoading = true;
  String? _linesError;

  List<TaxiInfo> _queue = [];
  bool _queueLoading = false;

  // taxiId → seats booked this session (optimistic)
  final Map<String, int> _sessionBooked = {};

  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  static const _socketOwner = 'booking_page';

  @override
  void initState() {
    super.initState();
    sl<BookingRefreshNotifier>().addListener(_onExternalBooking);
    Future.microtask(() {
      _subscribeToStation();
      _loadLines();
    });
  }

  @override
  void dispose() {
    sl<BookingRefreshNotifier>().removeListener(_onExternalBooking);
    sl<SocketService>().unsubscribeByOwner(_socketOwner);
    super.dispose();
  }

  void _onExternalBooking() {
    _loadLines();
    if (_selectedLine != null) _loadQueue(_selectedLine!.id, silent: true);
  }

  Future<void> _refresh() async {
    await _loadLines();
    if (_selectedLine != null) await _loadQueue(_selectedLine!.id);
  }

  String? get _stationId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.driver.station?.id : null;
  }

  Future<void> _loadLines() async {
    final stationId = _stationId;
    if (stationId == null) {
      setState(() {
        _linesLoading = false;
      });
      return;
    }
    try {
      final entities = await sl<GetLinesUseCase>()(stationId);
      if (!mounted) return;
      setState(() {
        _lines = entities
            .map((e) => LineInfo(
                  id: e.id,
                  origin: e.origin,
                  destination: e.destination,
                  price: e.price.toInt(),
                  taxiCount: e.activeTaxiCount,
                ))
            .toList();
        _linesLoading = false;
        _linesError = null;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _linesLoading = false;
          _linesError = e.toString();
        });
    }
  }

  Future<void> _loadQueue(String lineId, {bool silent = false}) async {
    final stationId = _stationId;
    if (stationId == null) return;
    if (!silent)
      setState(() {
        _queueLoading = true;
        _queue = [];
      });
    try {
      final entities = await sl<GetLineQueueUseCase>()(stationId, lineId);
      if (!mounted) return;
      setState(() {
        _queue = entities
            .map((e) => TaxiInfo(
                  id: e.id,
                  plateNumber: e.plateNumber,
                  totalSeats: e.totalSeats,
                  occupiedSeats: e.occupiedSeats,
                  status: 'En attente',
                  isFirst: e.isFirst,
                  color: e.color,
                  year: e.year,
                  driver: DriverInfo(
                    name: e.driver.name,
                    phone: e.driver.phone,
                    licenseNumber: e.driver.licenseNumber,
                    permitNumber: e.driver.permitNumber,
                    balance: e.driver.balance,
                  ),
                ))
            .toList();
        // API data is now authoritative — drop optimistic session counts
        for (final e in entities) {
          _sessionBooked.remove(e.id);
        }
        if (!silent) _queueLoading = false;
      });
    } catch (_) {
      if (mounted && !silent)
        setState(() {
          _queueLoading = false;
        });
    }
  }

  void _subscribeToStation() {
    final stationId = _stationId;
    if (stationId == null) return;
    sl<SocketService>().subscribe(SocketChannelConfig(
      channel: 'station/$stationId',
      handlerType: SocketHandlerType.data,
      owner: _socketOwner,
      onData: _onStationEvent,
    ));
  }

  void _onStationEvent(dynamic raw) {
    if (!mounted) return;
    final data = raw as Map<String, dynamic>?;
    if (data == null) return;

    final event = data['event'] as String?;
    final lineId = data['lineId'] as String?;

    switch (event) {
      case 'ticket_sold':
        // Optimistic: update seat count immediately for instant UI
        final taxiId = data['taxiId'] as String?;
        final seatsOccupied = (data['seatsOccupied'] as num?)?.toInt();
        if (taxiId != null && seatsOccupied != null) {
          setState(() {
            _queue = _queue
                .map((t) => t.id == taxiId
                    ? t.copyWith(occupiedSeats: seatsOccupied)
                    : t)
                .toList();
          });
        }
        // Silent reload to catch taxi removal when last seat is filled
        _loadLines();
        if (_selectedLine != null &&
            (_selectedLine!.id == lineId || lineId == null)) {
          _loadQueue(_selectedLine!.id, silent: true);
        }
      case 'taxi_queued':
      case 'taxi_departed':
        _loadLines();
        if (_selectedLine != null &&
            (_selectedLine!.id == lineId || lineId == null)) {
          _loadQueue(_selectedLine!.id, silent: true);
        }
      case 'taxi_line_changed':
        _loadLines();
        if (_selectedLine != null) _loadQueue(_selectedLine!.id, silent: true);
    }
  }

  int _availableFor(TaxiInfo taxi) {
    return taxi.availableSeats - (_sessionBooked[taxi.id] ?? 0);
  }

  // Cash: await API → get real ticket → print → show success
  Future<void> _bookSeats(TaxiInfo taxi, int count) async {
    final firstEligible = _queue.firstWhere(
      (t) => _availableFor(t) >= count,
      orElse: () => taxi,
    );
    if (firstEligible.id != taxi.id) {
      final l = AppLocalizations.of(context);
      final position = _queue.indexOf(firstEligible) + 1;
      showAppError(context,
          message: l.cannotReserveBeforeFirstFull(position,
              _availableFor(firstEligible), firstEligible.plateNumber));
      return;
    }

    if (_paymentMethod == 'cash') {
      // Optimistically reserve seats so buttons disable immediately
      setState(() =>
          _sessionBooked[taxi.id] = (_sessionBooked[taxi.id] ?? 0) + count);
      final result =
          await _callBookingApi(taxi: taxi, count: count, method: 'cash');
      if (result == null) {
        // API failed — roll back optimistic count
        setState(() => _sessionBooked[taxi.id] =
            (_sessionBooked[taxi.id]! - count).clamp(0, 999));
        return;
      }
      _printWithTicket(result, taxi, count);
      await _showSuccessDialog(count);
      if (!mounted) return;
      _maybeShowTaxiFullDialog(taxi);
      _loadLines();
      if (_selectedLine != null) _loadQueue(_selectedLine!.id, silent: true);
    } else {
      _showNfcDialog(taxi, count);
    }
  }

  // Returns result on success, null on error (error already shown via SnackBar)
  Future<BookingResultEntity?> _callBookingApi({
    required TaxiInfo taxi,
    required int count,
    required String method,
    String? nfcTagId,
  }) async {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated || _selectedLine == null) return null;
    try {
      return await sl<CreateBookingUseCase>()(CreateBookingParams(
        taxiId: taxi.id,
        lineId: _selectedLine!.id,
        seatCount: count,
        paymentMethod: method,
        cashierId: state.driver.id,
        nfcTagId: nfcTagId,
      ));
    } catch (e) {
      if (mounted) {
        showAppError(context, message: e.toString());
      }
      return null;
    }
  }

  void _printWithTicket(BookingResultEntity result, TaxiInfo taxi, int count) {
    final authState = context.read<AuthBloc>().state;
    final stationName = authState is AuthAuthenticated
        ? (authState.driver.station?.name ?? 'Station')
        : 'Station';
    final l = AppLocalizations.of(context);

    if (result.ticket != null) {
      //Todo: Printer active
      CashierPrinter.printTicket(
        ticket: result.ticket!.copyWith(seatNumber: count),
        stationName: stationName,
        l: l,
      );
    } else {
      CashierPrinter.printBooking(
        stationName: stationName,
        lineName: _selectedLine!
            .destination, //${_selectedLine!.origin} → ${_selectedLine!.destination}
        taxiNumber: taxi.plateNumber,
        seatCount: count,
        totalPrice: count * _selectedLine!.price.toDouble(),
        paymentMethod: _paymentMethod == 'cash' ? l.printCash : l.nfc,
        l: l,
      );
    }
  }

  Future<void> _showSuccessDialog(int count) {
    return showDialog(
      context: context,
      builder: (ctx) => SuccessDialog(count: count),
    );
  }

  void _maybeShowTaxiFullDialog(TaxiInfo taxi) {
    if (_selectedLine == null) return;
    final totalOccupied = taxi.occupiedSeats + (_sessionBooked[taxi.id] ?? 0);
    if (totalOccupied >= taxi.totalSeats) {
      //Todo: display the taxi full payment
      // showDialog(
      //   context: context,
      //   builder: (_) => TaxiFullPaymentDialog(
      //     taxi: taxi,
      //     pricePerSeat: _selectedLine!.price,
      //     lineOrigin: _selectedLine!.origin,
      //     lineDestination: _selectedLine!.destination,
      //   ),
      // );
    }
  }

  // NFC: dialog handles card scan + API call internally, returns result via onBooked
  void _showNfcDialog(TaxiInfo taxi, int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NfcScanDialog(
        line: _selectedLine!,
        taxi: taxi,
        seatCount: count,
        onBooking: (tagId) => _callBookingApi(
          taxi: taxi,
          count: count,
          method: 'nfc',
          nfcTagId: tagId,
        ),
        onBooked: (result) async {
          setState(() =>
              _sessionBooked[taxi.id] = (_sessionBooked[taxi.id] ?? 0) + count);
          _printWithTicket(result, taxi, count);
          await _showSuccessDialog(count);
          if (!mounted) return;
          _maybeShowTaxiFullDialog(taxi);
          _loadLines();
          if (_selectedLine != null)
            _loadQueue(_selectedLine!.id, silent: true);
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    final authState = context.watch<AuthBloc>().state;
    final driver = authState is AuthAuthenticated ? authState.driver : null;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // initState may have fired before auth check completed — retry here
        if (state is AuthAuthenticated && _lines.isEmpty && !_linesLoading) {
          _subscribeToStation();
          setState(() => _linesLoading = true);
          _loadLines();
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            l.bookingTitle,
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
                    color: AppColors.of(context).iconBg,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 24),
              ),
              tooltip: l.profile,
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: SafeArea(
          child: _selectedLine == null
              ? RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  backgroundColor: c.surface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStationCard(driver),
                        const SizedBox(height: 16),
                        _buildSectionLabel(l.sectionLines),
                        const SizedBox(height: 8),
                        _buildLinesGrid(l),
                        const SizedBox(height: 16),
                        _buildSectionLabel(l.sectionPayment),
                        const SizedBox(height: 8),
                        _buildPaymentRow(l),
                        const SizedBox(height: 16),
                        _buildHint(l),
                      ],
                    ),
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStationCard(driver),
                            const SizedBox(height: 16),
                            _buildSectionLabel(l.sectionLines),
                            const SizedBox(height: 8),
                            _buildLinesGrid(l),
                            const SizedBox(height: 16),
                            _buildSectionLabel(l.sectionPayment),
                            const SizedBox(height: 8),
                            _buildPaymentRow(l),
                            const SizedBox(height: 16),
                            _buildSectionLabel(
                                '${l.taxisInQueue} (${_selectedLine?.taxiCount})  ·  ${_selectedLine!.destination}'),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    backgroundColor: c.surface,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _buildTaxiCards(),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final c = AppColors.of(context);
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

  Widget _buildStationCard(driver) {
    final c = AppColors.of(context);
    final stationName = driver?.station?.name ?? '';
    final stationCity = driver?.station?.city ?? '';
    final stationCode = driver?.station?.code ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_city,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName.isNotEmpty ? stationName : '—',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stationCity.isNotEmpty)
                  Text(
                    stationCity,
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (stationCode.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stationCode,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinesGrid(AppLocalizations l) {
    if (_linesLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)),
      );
    }
    if (_linesError != null) {
      final c = AppColors.of(context);
      return GestureDetector(
        onTap: () {
          setState(() {
            _linesLoading = true;
            _linesError = null;
          });
          _loadLines();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: c.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(l.retry,
                  style: TextStyle(color: c.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    final maxHeight = MediaQuery.of(context).size.height / 4;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemCount: _lines.length,
          itemBuilder: (_, i) {
            final line = _lines[i];
            final selected = _selectedLine?.id == line.id;
            return LineCard(
              line: line,
              selected: selected,
              onTap: () {
                if (selected) {
                  setState(() {
                    _selectedLine = null;
                    _queue = [];
                  });
                } else {
                  setState(() => _selectedLine = line);
                  _loadQueue(line.id);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentRow(AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: PaymentButton(
            icon: Icons.payments_outlined,
            label: l.cash,
            selected: _paymentMethod == 'cash',
            onTap: () => setState(() => _paymentMethod = 'cash'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PaymentButton(
            icon: Icons.nfc,
            label: l.nfc,
            selected: _paymentMethod == 'nfc',
            onTap: () => setState(() => _paymentMethod = 'nfc'),
          ),
        ),
      ],
    );
  }

  Widget _buildHint(AppLocalizations l) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined, color: c.textSecondary, size: 34),
          const SizedBox(height: 10),
          Text(
            l.selectLineHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaxiCards() {
    if (_queueLoading) {
      return [
        const SizedBox(
          height: 80,
          child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2)),
        ),
      ];
    }

    final sorted = [..._queue];

    if (sorted.isEmpty) {
      final c = AppColors.of(context);
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context).noTaxiForLine,
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ];
    }

    return sorted.map((taxi) {
      final available = _availableFor(taxi);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TaxiCard(
          taxi: taxi,
          available: available,
          onSeatCount: (count) => _bookSeats(taxi, count),
        ),
      );
    }).toList();
  }
}

// ─── Stub pages kept for router compatibility ─────────────────────────────────

class NfcScanPage extends StatelessWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;
  const NfcScanPage(
      {super.key,
      required this.line,
      required this.taxi,
      required this.seatCount});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CashConfirmPage extends StatelessWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;
  const CashConfirmPage(
      {super.key,
      required this.line,
      required this.taxi,
      required this.seatCount});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
