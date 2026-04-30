import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashier/core/services/sunmi_nfc_service.dart';
import 'package:cashier/core/services/cashier_printer.dart';
import 'package:cashier/core/theme/app_theme.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/l10n/app_localizations.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class LineInfo {
  final String id;
  final String origin;
  final String destination;
  final int price;
  final int taxiCount;
  const LineInfo({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    this.taxiCount = 0,
  });
}

class DriverInfo {
  final String name;
  final String phone;
  final String licenseNumber;
  final String? permitNumber;
  final double balance;
  const DriverInfo({
    required this.name,
    required this.phone,
    required this.licenseNumber,
    this.permitNumber,
    required this.balance,
  });
}

class TaxiInfo {
  final String id;
  final String plateNumber;
  final int totalSeats;
  final int occupiedSeats;
  final String status;
  final DriverInfo driver;
  final String? color;
  final String? year;
  final bool isFirst;
  const TaxiInfo({
    required this.id,
    required this.plateNumber,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.status,
    required this.driver,
    this.color,
    this.year,
    this.isFirst = false,
  });

  int get availableSeats => totalSeats - occupiedSeats;
}

// ─── Mock Data ────────────────────────────────────────────────────────────────

const _mockLines = [
  LineInfo(id: 'l1', origin: 'Bab Doukkala', destination: 'Daoudiate', price: 6, taxiCount: 3),
  LineInfo(id: 'l2', origin: 'Bab Doukkala', destination: 'Mhamid', price: 6, taxiCount: 1),
  LineInfo(id: 'l3', origin: 'Bab Doukkala', destination: 'Médina', price: 4, taxiCount: 2),
  LineInfo(id: 'l4', origin: 'Bab Doukkala', destination: 'Jamaa El Fna', price: 5, taxiCount: 0),
  LineInfo(id: 'l5', origin: 'Guéliz', destination: 'Palmeraie', price: 8, taxiCount: 1),
];

const _mockTaxis = [
  TaxiInfo(
    id: 't1',
    plateNumber: '77777-A-7',
    totalSeats: 6,
    occupiedSeats: 2,
    status: 'En attente',
    isFirst: true,
    driver: DriverInfo(
      name: 'Ahmed Benali',
      phone: '+212 6 61 11 22 33',
      licenseNumber: 'M-2019-4521',
      permitNumber: 'P-2019-001',
      balance: 450.00,
    ),
    color: 'Blanc',
    year: '2019',
  ),
  TaxiInfo(
    id: 't2',
    plateNumber: '12345-B-3',
    totalSeats: 6,
    occupiedSeats: 3,
    status: 'En attente',
    isFirst: false,
    driver: DriverInfo(
      name: 'Youssef Alami',
      phone: '+212 6 62 33 44 55',
      licenseNumber: 'M-2021-0087',
      permitNumber: 'P-2021-022',
      balance: 220.00,
    ),
    color: 'Beige',
    year: '2021',
  ),
  TaxiInfo(
    id: 't3',
    plateNumber: '98765-C-1',
    totalSeats: 6,
    occupiedSeats: 5,
    status: 'En attente',
    isFirst: false,
    driver: DriverInfo(
      name: 'Khalid Mansouri',
      phone: '+212 6 63 55 66 77',
      licenseNumber: 'M-2018-3312',
      permitNumber: 'P-2018-045',
      balance: 310.00,
    ),
    color: 'Blanc',
    year: '2018',
  ),
];

// ─── Main Booking Page ────────────────────────────────────────────────────────

class CashierBookingPage extends StatefulWidget {
  const CashierBookingPage({super.key});

  @override
  State<CashierBookingPage> createState() => _CashierBookingPageState();
}

class _CashierBookingPageState extends State<CashierBookingPage> {
  LineInfo? _selectedLine;
  String _paymentMethod = 'cash';

  // taxiId → number of seats booked this session
  final Map<String, int> _sessionBooked = {};

  int _availableFor(TaxiInfo taxi) {
    return taxi.availableSeats - (_sessionBooked[taxi.id] ?? 0);
  }

  void _bookSeats(TaxiInfo taxi, int count) {
    if (_paymentMethod == 'cash') {
      setState(() => _sessionBooked[taxi.id] = (_sessionBooked[taxi.id] ?? 0) + count);
      _printTicket(taxi, count);
      _showSuccessDialog(count);
    } else {
      _showNfcDialog(taxi, count);
    }
  }

  void _printTicket(TaxiInfo taxi, int count) {
    final authState = context.read<AuthBloc>().state;
    final driver = authState is AuthAuthenticated ? authState.driver : null;
    CashierPrinter.printBooking(
      stationName: driver?.station?.name ?? 'Station',
      lineName: '${_selectedLine!.origin} → ${_selectedLine!.destination}',
      taxiNumber: taxi.plateNumber,
      seatCount: count,
      totalPrice: count * _selectedLine!.price.toDouble(),
      paymentMethod: _paymentMethod == 'cash' ? 'Cash' : 'NFC',
    );
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (ctx) => _SuccessDialog(count: count),
    );
  }

  void _showNfcDialog(TaxiInfo taxi, int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NfcScanDialog(
        line: _selectedLine!,
        taxi: taxi,
        seatCount: count,
        onSuccess: () {
          Navigator.of(ctx).pop();
          setState(() => _sessionBooked[taxi.id] = (_sessionBooked[taxi.id] ?? 0) + count);
          _printTicket(taxi, count);
          _showSuccessDialog(count);
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;
    final driver = authState is AuthAuthenticated ? authState.driver : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l.bookingTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primary),
            tooltip: l.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              if (_selectedLine == null)
                _buildHint(l)
              else ...[
                _buildSectionLabel(
                    '${l.taxisInQueue} (${_selectedLine?.taxiCount})  ·  ${_selectedLine!.destination}'),
                const SizedBox(height: 8),
                ..._buildTaxiCards(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Section helpers ──────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      );

  // ── Station Card ─────────────────────────────────────────────────────────

  Widget _buildStationCard(driver) {
    final stationName = driver?.station?.name ?? '';
    final stationCity = driver?.station?.city ?? '';
    final stationCode = driver?.station?.code ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stationCity.isNotEmpty)
                  Text(
                    stationCity,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (stationCode.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stationCode,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Lines Grid ───────────────────────────────────────────────────────────

  Widget _buildLinesGrid(AppLocalizations l) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: _mockLines.length,
      itemBuilder: (_, i) {
        final line = _mockLines[i];
        final selected = _selectedLine?.id == line.id;
        return _LineCard(
          line: line,
          selected: selected,
          onTap: () => setState(() {
            if (selected) {
              _selectedLine = null;
            } else {
              _selectedLine = line;
            }
          }),
        );
      },
    );
  }

  // ── Payment Method Row ───────────────────────────────────────────────────

  Widget _buildPaymentRow(AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: _PaymentButton(
            icon: Icons.payments_outlined,
            label: l.cash,
            selected: _paymentMethod == 'cash',
            onTap: () => setState(() => _paymentMethod = 'cash'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PaymentButton(
            icon: Icons.nfc,
            label: l.nfc,
            selected: _paymentMethod == 'nfc',
            onTap: () => setState(() => _paymentMethod = 'nfc'),
          ),
        ),
      ],
    );
  }

  // ── Hint ─────────────────────────────────────────────────────────────────

  Widget _buildHint(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.touch_app_outlined,
              color: AppColors.textSecondary, size: 34),
          const SizedBox(height: 10),
          Text(
            l.selectLineHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Taxi Cards ────────────────────────────────────────────────────────────

  List<Widget> _buildTaxiCards() {
    final sorted = [..._mockTaxis]
      ..sort((a, b) {
        if (a.isFirst && !b.isFirst) return -1;
        if (!a.isFirst && b.isFirst) return 1;
        return b.occupiedSeats.compareTo(a.occupiedSeats);
      });

    if (sorted.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context).noTaxiForLine,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ];
    }

    return sorted.map((taxi) {
      final available = _availableFor(taxi);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _TaxiCard(
          taxi: taxi,
          available: available,
          onSeatCount: (count) => _bookSeats(taxi, count),
        ),
      );
    }).toList();
  }
}

// ─── Line Grid Card ───────────────────────────────────────────────────────────

class _LineCard extends StatelessWidget {
  final LineInfo line;
  final bool selected;
  final VoidCallback onTap;

  const _LineCard({
    required this.line,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.near_me,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    line.destination,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.primary : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${line.price} DH',
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (line.taxiCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${line.taxiCount}',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )else Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${line.taxiCount}',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Button ───────────────────────────────────────────────────────────

class _PaymentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Taxi Card ────────────────────────────────────────────────────────────────

class _TaxiCard extends StatelessWidget {
  final TaxiInfo taxi;
  final int available;
  final ValueChanged<int> onSeatCount;

  const _TaxiCard({
    required this.taxi,
    required this.available,
    required this.onSeatCount,
  });

  bool get _isFull => available <= 0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isFull ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: taxi & driver info ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        taxi.plateNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (taxi.isFirst) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Builder(
                            builder: (ctx) => Text(
                              AppLocalizations.of(ctx).firstBadge,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    taxi.driver.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    taxi.driver.phone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isFull
                          ? AppColors.red.withValues(alpha: 0.12)
                          : AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFull
                            ? AppColors.red.withValues(alpha: 0.4)
                            : AppColors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Builder(builder: (ctx) {
                      final l = AppLocalizations.of(ctx);
                      return Text(
                        _isFull ? l.full : l.freeSeats(available),
                        style: TextStyle(
                          color: _isFull ? AppColors.red : AppColors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Right: seat count buttons (1–6) ─────────────────────────
            // Each button = "book N seats". Disabled if N > available.
            SizedBox(
              width: 200,
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.end,
                children: List.generate(taxi.totalSeats, (i) {
                  final count = i + 1;
                  final isDisabled = count > available;
                  return _SeatButton(
                    number: count,
                    isDisabled: isDisabled,
                    onTap: isDisabled ? null : () => onSeatCount(count),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Seat Button ──────────────────────────────────────────────────────────────

class _SeatButton extends StatelessWidget {
  final int number;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _SeatButton({
    required this.number,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color text;

    if (isDisabled) {
      bg = AppColors.iconBg;
      border = AppColors.border;
      text = AppColors.textSecondary.withValues(alpha: 0.5);
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
            style: TextStyle(
              color: text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  final int count;
  const _SuccessDialog({required this.count});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.green, width: 2),
              ),
              child: const Icon(Icons.check, color: AppColors.green, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              l.bookingConfirmed,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.seatsBookedSuccess(count),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  l.ok,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── NFC Scan Dialog ──────────────────────────────────────────────────────────

class _NfcScanDialog extends StatefulWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _NfcScanDialog({
    required this.line,
    required this.taxi,
    required this.seatCount,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_NfcScanDialog> createState() => _NfcScanDialogState();
}

class _NfcScanDialogState extends State<_NfcScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<Map<String, dynamic>>? _nfcSub;

  bool _scanning = true;

  int get _total => widget.seatCount * widget.line.price;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    SunmiNfcService.localHandlerActive = true;
    SunmiNfcService.startScanning();
    _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
      if (event['event'] == 'CARD_FOUND' && _scanning && mounted) {
        _onCardDetected();
      }
    });
  }

  void _onCardDetected() {
    if (!mounted || !_scanning) return;
    _pulseCtrl.stop();
    setState(() => _scanning = false);
    widget.onSuccess();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _nfcSub?.cancel();
    SunmiNfcService.stopScanning();
    SunmiNfcService.localHandlerActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: _buildScanning(),
    );
  }

  Widget _buildScanning() {
    final l = AppLocalizations.of(context);
    return Padding(
      key: const ValueKey('scanning'),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.nfc, color: AppColors.primary, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.nfcReading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.seatCount} ${l.seats}  ·  $_total DH',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.nfcApproach,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Simulate button (for testing without real NFC hardware)
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton.icon(
          //     onPressed: _onCardDetected,
          //     icon: const Icon(Icons.nfc, size: 16),
          //     label: Text(l.nfcSimulate),
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: AppColors.primary,
          //       side: BorderSide(
          //           color: AppColors.primary.withValues(alpha: 0.5)),
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10)),
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

}

// ─── NFC Scan Page (kept for router compatibility) ───────────────────────────

class _PassengerData {
  final String id;
  final String name;
  final String phone;
  final double balance;
  const _PassengerData({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });
}

class NfcScanPage extends StatefulWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;

  const NfcScanPage({
    super.key,
    required this.line,
    required this.taxi,
    required this.seatCount,
  });

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  StreamSubscription<Map<String, dynamic>>? _nfcSub;

  bool _scanning = true;
  bool _loadingPassenger = false;
  _PassengerData? _passenger;
  bool _processing = false;

  static const _mockPassenger = _PassengerData(
    id: 'USR-00142',
    name: 'Mohammed El Fassi',
    phone: '+212 6 61 23 45 67',
    balance: 150.00,
  );

  int get _total => widget.seatCount * widget.line.price;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // SunmiNfcService.startScanning(); // NFC disabled
    // _nfcSub = SunmiNfcService.allEventsStream().listen((event) {
    //   if (event['event'] == 'CARD_FOUND' && _scanning && mounted) {
    //     _onCardDetected(event['details']?.toString() ?? '');
    //   }
    // });
  }

  // ignore: unused_element
  Future<void> _onCardDetected(String tagId) async {
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _loadingPassenger = true;
    });
    _pulseController.stop();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _loadingPassenger = false;
      _passenger = _mockPassenger;
    });
  }

  Future<void> _confirmPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nfcSub?.cancel();
    // SunmiNfcService.stopScanning(); // NFC disabled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Paiement NFC',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (_scanning || _loadingPassenger)
              ? _buildScanningView()
              : _buildPaymentView(),
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Padding(
      key: const ValueKey('scanning'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _InfoCard(
            label: 'TRANSACTION',
            children: [
              _SummaryRow(
                  icon: Icons.near_me,
                  label: 'Destination',
                  value: widget.line.destination),
              const _CardDivider(),
              _SummaryRow(
                  icon: Icons.local_taxi,
                  label: 'Taxi',
                  value: widget.taxi.plateNumber),
              const _CardDivider(),
              _SummaryRow(
                  icon: Icons.event_seat,
                  label: 'Places',
                  value: '${widget.seatCount}'),
              const _CardDivider(),
              _SummaryRow(
                icon: Icons.payments_outlined,
                label: 'Montant',
                value: '$_total DH',
                valueColor: AppColors.primary,
              ),
            ],
          ),
          const Spacer(),
          if (_loadingPassenger)
            const Column(
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Identification en cours...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            )
          else
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.nfc, color: AppColors.primary, size: 60),
              ),
            ),
          if (!_loadingPassenger) ...[
            const SizedBox(height: 24),
            const Text(
              'En attente du scan NFC',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Approchez la carte du passager\npour valider le paiement',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentView() {
    final passenger = _passenger!;
    final driverBalance = widget.taxi.driver.balance;
    final newDriverBalance = driverBalance + _total;
    final passengerNewBalance = passenger.balance - _total;
    final canPay = passenger.balance >= _total;

    return Padding(
      key: const ValueKey('payment'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.green, width: 1.5),
                      ),
                      child: const Icon(Icons.person_pin,
                          color: AppColors.green, size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Passager identifié',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 20),
                  _InfoCard(
                    label: 'PASSAGER',
                    children: [
                      _SummaryRow(
                          icon: Icons.person_outline,
                          label: 'Nom',
                          value: passenger.name),
                      const _CardDivider(),
                      _SummaryRow(
                          icon: Icons.phone_outlined,
                          label: 'Téléphone',
                          value: passenger.phone),
                      const _CardDivider(),
                      _SummaryRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Solde actuel',
                        value:
                            '${passenger.balance.toStringAsFixed(2)} DH',
                        valueColor:
                            canPay ? AppColors.green : AppColors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'TRANSACTION',
                    children: [
                      _SummaryRow(
                          icon: Icons.near_me,
                          label: 'Destination',
                          value: widget.line.destination),
                      const _CardDivider(),
                      _SummaryRow(
                          icon: Icons.event_seat,
                          label: 'Places',
                          value: '${widget.seatCount}'),
                      const _CardDivider(),
                      _SummaryRow(
                        icon: Icons.payments_outlined,
                        label: 'Montant',
                        value: '$_total DH',
                        valueColor: AppColors.primary,
                      ),
                      const _CardDivider(),
                      _SummaryRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Solde après paiement',
                        value:
                            '${passengerNewBalance.toStringAsFixed(2)} DH',
                        valueColor: canPay
                            ? AppColors.textSecondary
                            : AppColors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'CHAUFFEUR',
                    children: [
                      _SummaryRow(
                          icon: Icons.person_outline,
                          label: 'Nom',
                          value: widget.taxi.driver.name),
                      const _CardDivider(),
                      _SummaryRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Solde actuel',
                        value:
                            '${driverBalance.toStringAsFixed(2)} DH',
                        valueColor: AppColors.textSecondary,
                      ),
                      const _CardDivider(),
                      _SummaryRow(
                        icon: Icons.trending_up,
                        label: 'Après encaissement',
                        value:
                            '${newDriverBalance.toStringAsFixed(2)} DH',
                        valueColor: AppColors.green,
                      ),
                    ],
                  ),
                  if (!canPay) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.red, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Solde insuffisant pour ce paiement',
                              style: TextStyle(
                                  color: AppColors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (canPay && !_processing) ? _confirmPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _processing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Confirmer le paiement',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _processing
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ─── Cash Confirm Page ────────────────────────────────────────────────────────

class CashConfirmPage extends StatelessWidget {
  final LineInfo line;
  final TaxiInfo taxi;
  final int seatCount;

  const CashConfirmPage({
    super.key,
    required this.line,
    required this.taxi,
    required this.seatCount,
  });

  int get _total => seatCount * line.price;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Confirmation Cash',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.green, width: 2),
                  ),
                  child: const Icon(Icons.payments_outlined,
                      color: AppColors.green, size: 30),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Résumé du paiement',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Paiement en espèces',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _InfoCard(
                        label: 'TRAJET',
                        children: [
                          _SummaryRow(
                              icon: Icons.near_me,
                              label: 'Destination',
                              value: line.destination),
                          const _CardDivider(),
                          _SummaryRow(
                              icon: Icons.payments_outlined,
                              label: 'Prix / place',
                              value: '${line.price} DH'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        label: 'TAXI',
                        children: [
                          _SummaryRow(
                              icon: Icons.local_taxi,
                              label: 'Immatriculation',
                              value: taxi.plateNumber),
                          if (taxi.color != null) ...[
                            const _CardDivider(),
                            _SummaryRow(
                                icon: Icons.palette_outlined,
                                label: 'Couleur',
                                value: taxi.color!),
                          ],
                          if (taxi.year != null) ...[
                            const _CardDivider(),
                            _SummaryRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Année',
                                value: taxi.year!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        label: 'CHAUFFEUR',
                        children: [
                          _SummaryRow(
                              icon: Icons.person_outline,
                              label: 'Nom',
                              value: taxi.driver.name),
                          const _CardDivider(),
                          _SummaryRow(
                              icon: Icons.phone_outlined,
                              label: 'Téléphone',
                              value: taxi.driver.phone),
                          const _CardDivider(),
                          _SummaryRow(
                              icon: Icons.badge_outlined,
                              label: 'Permis conduire',
                              value: taxi.driver.licenseNumber),
                          if (taxi.driver.permitNumber != null) ...[
                            const _CardDivider(),
                            _SummaryRow(
                                icon: Icons.assignment_outlined,
                                label: 'N° Autorisation',
                                value: taxi.driver.permitNumber!),
                          ],
                          const _CardDivider(),
                          _SummaryRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Solde',
                            value:
                                '${taxi.driver.balance.toStringAsFixed(2)} DH',
                            valueColor: AppColors.teal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        label: 'PAIEMENT',
                        children: [
                          _SummaryRow(
                              icon: Icons.event_seat,
                              label: 'Nombre de places',
                              value: '$seatCount'),
                          const _CardDivider(),
                          _SummaryRow(
                              icon: Icons.payments_outlined,
                              label: 'Prix unitaire',
                              value: '${line.price} DH'),
                          const _CardDivider(),
                          _SummaryRow(
                            icon: Icons.calculate_outlined,
                            label: 'TOTAL',
                            value: '$_total DH',
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Valider & Encaisser',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared helper widgets ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _InfoCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: AppColors.border, height: 1),
      );
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
