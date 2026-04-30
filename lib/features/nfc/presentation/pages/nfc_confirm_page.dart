import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashier/core/l10n/app_localizations.dart';
import 'package:cashier/core/theme/app_theme.dart';

class NfcConfirmPage extends StatefulWidget {
  final String nfcTagId;

  const NfcConfirmPage({super.key, required this.nfcTagId});

  @override
  State<NfcConfirmPage> createState() => _NfcConfirmPageState();
}

class _NfcConfirmPageState extends State<NfcConfirmPage> {
  _ClientInfo? _client;
  bool _loading = true;
  bool _adding = false;
  _LineInfo? _selectedLine;
  int? _selectedSeat;
  bool _tripsExpanded = false;

  static const int _totalSeats = 6;

  // ── Mock data ────────────────────────────────────────────────────────────
  static const _mockclient = _ClientInfo(
    id: 'DRV-00142',
    name: 'Mohammed El Fassi',
    phone: '+212 6 61 23 45 67',
    balance: 240.50,
    trips: [
      _TripInfo(from: 'Bab Doukkala', to: 'Daoudiate'),
      _TripInfo(from: 'Bab Doukkala', to: 'Daoudiate'),
      _TripInfo(from: 'Bab Doukkala', to: 'Mhamid'),
    ],
  );

  static const _lines = [
    _LineInfo(
        id: '69dd30c25fe760cb0e04f493',
        origin: 'Bab Doukkala',
        destination: 'Daoudiate',
        price: 6),
    _LineInfo(
        id: '69dd30b15fe760cb0e04f48d',
        origin: 'Bab Doukkala',
        destination: 'Mhamid',
        price: 6),
    _LineInfo(
        id: '69dd30b15fe760cb0e04f49a',
        origin: 'Bab Doukkala',
        destination: 'Medina',
        price: 4),
    _LineInfo(
        id: '69dd30b15fe760cb0e04f4b1',
        origin: 'Bab Doukkala',
        destination: 'Jamaa El Fna',
        price: 5),
  ];

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _client = _mockclient;
        _loading = false;
      });
    }
  }

  Future<void> _addToQueue() async {
    if (_client == null || _selectedLine == null || _selectedSeat == null)
      return;
    setState(() => _adding = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _adding = false);
      context.go('/home');
    }
  }

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
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _ContentView(
                client: _client!,
                lines: _lines,
                selectedLine: _selectedLine,
                selectedSeat: _selectedSeat,
                totalSeats: _totalSeats,
                tripsExpanded: _tripsExpanded,
                onTripsToggled: () =>
                    setState(() => _tripsExpanded = !_tripsExpanded),
                onLineSelected: (line) => setState(() => _selectedLine = line),
                onSeatSelected: (seat) => setState(() => _selectedSeat = seat),
                adding: _adding,
                onAdd: _addToQueue,
                l: l,
              ),
      ),
    );
  }
}

// ─── Content view ─────────────────────────────────────────────────────────────
class _ContentView extends StatelessWidget {
  final _ClientInfo client;
  final List<_LineInfo> lines;
  final _LineInfo? selectedLine;
  final int? selectedSeat;
  final int totalSeats;
  final bool tripsExpanded;
  final VoidCallback onTripsToggled;
  final ValueChanged<_LineInfo> onLineSelected;
  final ValueChanged<int> onSeatSelected;
  final bool adding;
  final VoidCallback onAdd;
  final AppLocalizations l;

  const _ContentView({
    required this.client,
    required this.lines,
    required this.selectedLine,
    required this.selectedSeat,
    required this.totalSeats,
    required this.tripsExpanded,
    required this.onTripsToggled,
    required this.onLineSelected,
    required this.onSeatSelected,
    required this.adding,
    required this.onAdd,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── NFC badge ──────────────────────────────────────────────
                // Center(
                //   child: Container(
                //     width: 64,
                //     height: 64,
                //     decoration: BoxDecoration(
                //       color: AppColors.primary.withValues(alpha: 0.12),
                //       shape: BoxShape.circle,
                //       border: Border.all(color: AppColors.primary, width: 1.5),
                //     ),
                //     child: const Icon(Icons.nfc, color: AppColors.primary, size: 30),
                //   ),
                // ),
                // const SizedBox(height: 6),
                // Center(
                //   child: Text(
                //     l.nfcIdentified,
                //     style: const TextStyle(
                //       color: AppColors.textSecondary,
                //       fontSize: 12,
                //       letterSpacing: 0.4,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 32),

                // ── Balance card ───────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.balance,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${client.balance.toStringAsFixed(2)} MAD',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Passenger info card ────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                          icon: Icons.person_outline,
                          label: l.passengerLabel,
                          value: client.name),
                      const _Divider(),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: l.phone,
                          value: client.phone),
                    ],
                  ),
                ),
                // const SizedBox(height: 16),

                // // ── Recent trips — collapsible ─────────────────────────────
                // GestureDetector(
                //   onTap: onTripsToggled,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                //     decoration: BoxDecoration(
                //       color: AppColors.surface,
                //       borderRadius: tripsExpanded
                //           ? const BorderRadius.vertical(top: Radius.circular(16))
                //           : BorderRadius.circular(16),
                //       border: Border.all(color: AppColors.border),
                //     ),
                //     child: Row(
                //       children: [
                //         const Icon(Icons.history, color: AppColors.primary, size: 18),
                //         const SizedBox(width: 10),
                //         Expanded(
                //           child: Text(
                //             l.recentTrips,
                //             style: const TextStyle(
                //               color: Colors.white,
                //               fontSize: 13,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //         ),
                //         Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //           decoration: BoxDecoration(
                //             color: AppColors.primary.withValues(alpha: 0.15),
                //             borderRadius: BorderRadius.circular(20),
                //           ),
                //           child: Text(
                //             '${client.trips.length}',
                //             style: const TextStyle(
                //               color: AppColors.primary,
                //               fontSize: 11,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         AnimatedRotation(
                //           turns: tripsExpanded ? 0.5 : 0,
                //           duration: const Duration(milliseconds: 200),
                //           child: const Icon(
                //             Icons.keyboard_arrow_down,
                //             color: AppColors.textSecondary,
                //             size: 20,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Animated trips list
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                        left: BorderSide(color: AppColors.border),
                        right: BorderSide(color: AppColors.border),
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Column(
                      children: client.trips.asMap().entries.map((e) {
                        final isLast = e.key == client.trips.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${e.key + 1}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      e.value.from,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 1,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.4),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            color: AppColors.primary, size: 9),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value.to,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                  color: AppColors.border,
                                  height: 1,
                                  thickness: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  crossFadeState: tripsExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),

                const SizedBox(height: 20),

                // ── Seat picker ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l.seats,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _SeatPicker(
                  totalSeats: totalSeats,
                  selectedSeat: selectedSeat,
                  onSeatTap: onSeatSelected,
                ),

                const SizedBox(height: 20),

                // ── Line selector ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l.selectLine,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...lines.map((line) => _LineCard(
                      line: line,
                      isSelected: selectedLine?.id == line.id,
                      onTap: () => onLineSelected(line),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── Bottom CTA — original style ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (adding || selectedLine == null || selectedSeat == null)
                          ? null
                          : onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: adding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          l.addSeat,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(l.cancel,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Line card ────────────────────────────────────────────────────────────────
class _LineCard extends StatelessWidget {
  final _LineInfo line;
  final bool isSelected;
  final VoidCallback onTap;

  const _LineCard({
    required this.line,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: 1.5,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
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
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '→ ${line.destination}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${line.price} MAD',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
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

// ─── Info row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
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
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1, thickness: 1);
}

// ─── Seat picker ─────────────────────────────────────────────────────────────

class _SeatPicker extends StatelessWidget {
  final int totalSeats;
  final int? selectedSeat;
  final ValueChanged<int> onSeatTap;

  const _SeatPicker({
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
          padding: const EdgeInsets.only(right: 10),
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

  const _SeatBtn({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

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

// ─── Models ───────────────────────────────────────────────────────────────────
class _ClientInfo {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final List<_TripInfo> trips;

  const _ClientInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.trips,
  });
}

class _TripInfo {
  final String from;
  final String to;

  const _TripInfo({required this.from, required this.to});
}

class _LineInfo {
  final String id;
  final String origin;
  final String destination;
  final int price;

  const _LineInfo({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });
}
