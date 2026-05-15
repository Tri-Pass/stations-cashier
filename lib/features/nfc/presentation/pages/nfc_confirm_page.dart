import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/di/injection.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:cashier/features/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:cashier/features/drivers/domain/entities/nfc_driver_info.dart';
import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/usecases/get_lines_usecase.dart';
import 'package:cashier/features/lines/domain/usecases/get_line_queue_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/get_passenger_by_nfc_usecase.dart';
import 'package:cashier/core/services/cashier_printer.dart';
import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:cashier/core/widgets/app_notification.dart';
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
  // ── Shared state ─────────────────────────────────────────────────────────
  bool _loading = true;
  String? _loadError;
  bool _adding = false;
  NfcLineInfo? _selectedLine;
  List<NfcLineInfo> _availableLines = [];

  // ── Driver mode ──────────────────────────────────────────────────────────
  bool? _isDriverMode;
  NfcDriverInfo? _driver;

  // ── Passenger mode ───────────────────────────────────────────────────────
  NfcClientInfo? _client;
  int? _selectedSeat;
  String? _resolvedTaxiId;
  List<QueueTaxiEntity> _taxiQueue = [];
  bool _tripsExpanded = false;
  bool _isResolvingTaxi = false;

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
    setState(() {
      _loading = true;
      _loadError = null;
    });

    // Both NFC lookups run in parallel; individual failures are swallowed.
    NfcDriverInfo? driver;
    dynamic passenger;

    final driverFut = (() async {
      try {
        driver =
            await sl<DriverRemoteDataSource>().lookupByNfc(widget.nfcTagId);
      } catch (_) {}
    })();

    final passengerFut = (() async {
      try {
        passenger = await sl<GetPassengerByNfcUseCase>()(widget.nfcTagId);
      } catch (_) {}
    })();

    await Future.wait([driverFut, passengerFut]);

    if (!mounted) return;

    if (driver == null && passenger == null) {
      setState(() {
        _loading = false;
        _loadError = AppLocalizations.of(context).tagNotRecognized;
      });
      return;
    }

    // Load lines now that we know we have a valid tag.
    List<StationLineEntity> linesRaw = [];
    if (stationId != null) {
      try {
        linesRaw = await sl<GetLinesUseCase>()(stationId);
      } catch (_) {}
    }

    if (!mounted) return;

    final lines = linesRaw
        .map((e) => NfcLineInfo(
              id: e.id,
              origin: e.origin,
              destination: e.destination,
              price: e.price.toInt(),
            ))
        .toList();

    if (driver != null) {
      setState(() {
        _isDriverMode = true;
        _driver = driver;
        _availableLines = lines;
        _loading = false;
      });
    } else {
      setState(() {
        _isDriverMode = false;
        _client = NfcClientInfo(
          id: passenger.id,
          name: passenger.name,
          phone: passenger.phone,
          balance: passenger.balance,
          trips: (passenger.recentTrips as List)
              .map((t) => NfcTripInfo(from: t.from, to: t.to))
              .toList(),
        );
        _availableLines = lines;
        _loading = false;
      });
    }
  }

  // ── Queue resolution (passenger) ─────────────────────────────────────────

  Future<void> _resolveFirstTaxi(String lineId) async {
    final stationId = _stationId;
    if (stationId == null) return;
    setState(() => _isResolvingTaxi = true);
    try {
      final queue = await sl<GetLineQueueUseCase>()(stationId, lineId);
      if (!mounted) return;
      final first = queue.isEmpty
          ? null
          : queue.firstWhere((t) => t.isFirst, orElse: () => queue.first);
      setState(() {
        _taxiQueue = queue;
        _resolvedTaxiId = first?.id;
        _isResolvingTaxi = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isResolvingTaxi = false);
    }
  }

  // ── Seat validation dialog (passenger) ───────────────────────────────────

  Future<bool> _showSeatValidationDialog(int available,
      {required bool hasNext}) async {
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return AlertDialog(
          backgroundColor: c.surface,
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
                  style: TextStyle(
                      color: c.textPrimary,
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
            style: TextStyle(color: c.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel, style: TextStyle(color: c.textSecondary)),
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
        );
      },
    );
    return result == true;
  }

  // ── Booking (passenger) ──────────────────────────────────────────────────

  Future<void> _addPassengerToQueue() async {
    if (_client == null || _selectedLine == null || _selectedSeat == null) {
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final taxiId = _resolvedTaxiId;
    if (taxiId == null) {
      showAppError(context,
          message: AppLocalizations.of(context).noTaxiForLine);
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
        return _addPassengerToQueue();
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
        //Todo: Printer active
        await CashierPrinter.printTicket(
          ticket: ticket.copyWith(seatNumber: _selectedSeat!),
          stationName: authState.driver.station?.name ?? '',
          l: AppLocalizations.of(context),
        );
      }

      if (mounted) {
        sl<BookingRefreshNotifier>().refresh();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _adding = false);
        showAppError(context, message: e.toString());
      }
    }
  }

  // ── Enqueue (driver) ─────────────────────────────────────────────────────

  Future<void> _addDriverToQueue() async {
    if (_driver == null) return;
    if (_selectedLine == null) {
      showAppError(context, message: AppLocalizations.of(context).lineRequired);
      return;
    }
    setState(() => _adding = true);
    try {
      await sl<DriverRemoteDataSource>()
          .enqueue(_driver!.id, _selectedLine!.id);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _adding = false);
        showAppError(context, message: e.toString());
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: c.textPrimary, size: 18),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          _isDriverMode == null
              ? l.nfcScanning
              : _isDriverMode == true
                  ? l.driverProfile
                  : l.nfcDetected,
          style: TextStyle(
              color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _loadError != null
                ? _buildError(l)
                : _isDriverMode == true
                    ? _buildDriverContent(l)
                    : _buildPassengerContent(l),
      ),
    );
  }

  // ── Driver content ────────────────────────────────────────────────────────

  Widget _buildDriverContent(AppLocalizations l) {
    if (_driver!.alreadyQueued) return _buildAlreadyQueuedContent(l);
    return _buildEnqueueContent(l);
  }

  Widget _buildAlreadyQueuedContent(AppLocalizations l) {
    final c = AppColors.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DriverCard(driver: _driver!, l: l),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.playlist_add_check_rounded,
                            color: AppColors.teal, size: 34),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.alreadyInQueue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.alreadyInQueueSub,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(l.close,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnqueueContent(AppLocalizations l) {
    final c = AppColors.of(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DriverCard(driver: _driver!, l: l),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.selectLine,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    if (_availableLines.isNotEmpty)
                      Text(
                        '${_availableLines.length} ${l.lineLabel}s',
                        style: TextStyle(color: c.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_availableLines.isEmpty)
                  const _EmptyLines()
                else
                  NfcConfirmLineList(
                    lines: _availableLines,
                    selectedLine: _selectedLine,
                    onLineSelected: (line) =>
                        setState(() => _selectedLine = line),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: c.background,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _adding ? null : _addDriverToQueue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _adding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(l.addToQueue,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(l.cancel, style: TextStyle(color: c.textSecondary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Passenger content ─────────────────────────────────────────────────────

  Widget _buildPassengerContent(AppLocalizations l) {
    final c = AppColors.of(context);
    final isResolving = _isResolvingTaxi;

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
                      style: TextStyle(
                          color: c.textSecondary,
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
                        _isResolvingTaxi = false;
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
                      style: TextStyle(
                          color: c.textSecondary,
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
                      _isResolvingTaxi = false;
                    });
                    _resolveFirstTaxi(line.id);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildPassengerBottomCta(l, isResolving),
      ],
    );
  }

  Widget _buildPassengerBottomCta(AppLocalizations l, bool isResolving) {
    final c = AppColors.of(context);
    final disabled = _adding ||
        isResolving ||
        _selectedLine == null ||
        _selectedSeat == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: disabled ? null : _addPassengerToQueue,
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
            child: Text(l.cancel, style: TextStyle(color: c.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppLocalizations l) {
    final c = AppColors.of(context);
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
              style: TextStyle(color: c.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
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

// ─── Driver card ───────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  final NfcDriverInfo driver;
  final AppLocalizations l;

  const _DriverCard({required this.driver, required this.l});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: l.taxiNumberLabel,
              value: driver.taxiNumber),
          const _Divider(),
          _InfoRow(
              icon: Icons.person_outline,
              label: l.driverLabel,
              value: driver.name),
          const _Divider(),
          _InfoRow(
              icon: Icons.phone_outlined, label: l.phone, value: driver.phone),
          const _Divider(),
          _InfoRow(
              icon: Icons.location_on_outlined,
              label: l.destination,
              value: driver.destination),
          const _Divider(),
          _InfoRow(
              icon: Icons.event_seat_outlined,
              label: l.seats,
              value: '${driver.seatsTotal} ${l.seatsAvailable}'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: c.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Divider(color: c.border, height: 1, thickness: 1);
  }
}

class _EmptyLines extends StatelessWidget {
  const _EmptyLines();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.route_outlined, color: c.textSecondary, size: 40),
          const SizedBox(height: 10),
          Text('Aucune ligne disponible',
              style: TextStyle(color: c.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
