import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';

class CashoutStatsModel {
  final int totalTickets;
  final double totalCollected;
  final double totalNfc;
  final double totalCash;
  final double totalPayouts;
  final double totalRemaining;

  const CashoutStatsModel({
    required this.totalTickets,
    required this.totalCollected,
    required this.totalNfc,
    required this.totalCash,
    required this.totalPayouts,
    required this.totalRemaining,
  });

  factory CashoutStatsModel.fromJson(Map<String, dynamic> json) =>
      CashoutStatsModel(
        totalTickets:
            ((json['totalTickets'] ?? json['total_tickets'] ?? 0) as num)
                .toInt(),
        totalCollected:
            ((json['totalCollected'] ?? json['total_collected'] ?? 0) as num)
                .toDouble(),
        totalNfc:
            ((json['totalNfc'] ?? json['total_nfc'] ?? 0) as num).toDouble(),
        totalCash:
            ((json['totalCash'] ?? json['total_cash'] ?? 0) as num).toDouble(),
        totalPayouts:
            ((json['totalPayouts'] ?? json['total_payouts'] ?? 0) as num)
                .toDouble(),
        totalRemaining:
            ((json['totalRemaining'] ?? json['total_remaining'] ?? 0) as num)
                .toDouble(),
      );

  CashoutStatsEntity toEntity() => CashoutStatsEntity(
        totalTickets: totalTickets,
        totalCollected: totalCollected,
        totalNfc: totalNfc,
        totalCash: totalCash,
        totalPayouts: totalPayouts,
        totalRemaining: totalRemaining,
      );
}

class CashoutDriverModel {
  final String id;
  final String name;
  final String phone;
  const CashoutDriverModel(
      {required this.id, required this.name, required this.phone});

  factory CashoutDriverModel.fromJson(Map<String, dynamic> json) =>
      CashoutDriverModel(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
      );

  CashoutDriverEntity toEntity() =>
      CashoutDriverEntity(id: id, name: name, phone: phone);
}

class CashoutTaxiModel {
  final String id;
  final String plateNumber;
  const CashoutTaxiModel({required this.id, required this.plateNumber});

  factory CashoutTaxiModel.fromJson(Map<String, dynamic> json) =>
      CashoutTaxiModel(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        plateNumber:
            (json['plate_number'] ?? json['plateNumber'] ?? '') as String,
      );

  CashoutTaxiEntity toEntity() =>
      CashoutTaxiEntity(id: id, plateNumber: plateNumber);
}

class CashoutLineModel {
  final String id;
  final String origin;
  final String destination;
  final double price;
  const CashoutLineModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });

  factory CashoutLineModel.fromJson(Map<String, dynamic> json) =>
      CashoutLineModel(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        origin: (json['origin'] ?? '') as String,
        destination: (json['destination'] ?? '') as String,
        price: ((json['price'] ?? 0) as num).toDouble(),
      );

  factory CashoutLineModel.fromLineString(String lineStr) {
    final parts = lineStr.split(' → ');
    if (parts.length == 2) {
      return CashoutLineModel(
          id: '',
          origin: parts[0].trim(),
          destination: parts[1].trim(),
          price: 0);
    }
    return CashoutLineModel(id: '', origin: lineStr, destination: '', price: 0);
  }

  CashoutLineEntity toEntity() => CashoutLineEntity(
      id: id, origin: origin, destination: destination, price: price);
}

class CashoutSummaryModel {
  final String id;
  final CashoutDriverModel driver;
  final CashoutTaxiModel taxi;
  final CashoutLineModel line;
  final int totalSeats;
  final double totalAmount;
  final int cashSeats;
  final int nfcSeats;
  final double cashAmount;
  final double nfcAmount;
  final double totalPaid;
  final double remaining;
  final DateTime? departedAt;

  const CashoutSummaryModel({
    required this.id,
    required this.driver,
    required this.taxi,
    required this.line,
    required this.totalSeats,
    required this.totalAmount,
    this.cashSeats = 0,
    this.nfcSeats = 0,
    this.cashAmount = 0,
    this.nfcAmount = 0,
    this.totalPaid = 0,
    this.remaining = 0,
    this.departedAt,
  });

  factory CashoutSummaryModel.fromJson(Map<String, dynamic> json) {
    final driverRaw = json['driver'] as Map<String, dynamic>?;
    final taxiRaw = json['taxi'] as Map<String, dynamic>?;
    final lineRaw =
        json['line'] is Map ? json['line'] as Map<String, dynamic> : null;
    final departedRaw = (json['departed_at'] ?? json['departedAt']) as String?;

    // API uses ticketsCount; fall back to snake/camel variants
    final totalSeats = ((json['ticketsCount'] ??
            json['total_seats'] ??
            json['totalSeats'] ??
            0) as num)
        .toInt();
    // API uses totalCollected as the amount due
    final totalAmount = ((json['totalCollected'] ??
            json['remaining'] ??
            json['total_amount'] ??
            json['totalAmount'] ??
            0) as num)
        .toDouble();
    // API sends amounts directly (not seat counts)
    final cashAmount = ((json['totalCash'] ??
            json['cash_amount'] ??
            json['cashAmount'] ??
            0) as num)
        .toDouble();
    final nfcAmount = ((json['totalNfc'] ??
            json['nfc_amount'] ??
            json['nfcAmount'] ??
            0) as num)
        .toDouble();
    final totalPaid = ((json['totalPaid'] ?? json['total_paid'] ?? 0) as num)
        .toDouble();
    final remaining =
        ((json['remaining'] ?? json['remainingAmount'] ?? 0) as num).toDouble();

    // Parse line: prefer explicit line object, then taxi.line string
    final CashoutLineModel line;
    if (lineRaw != null) {
      line = CashoutLineModel.fromJson(lineRaw);
    } else if (taxiRaw != null && taxiRaw['line'] is String) {
      line = CashoutLineModel.fromLineString(taxiRaw['line'] as String);
    } else {
      line =
          const CashoutLineModel(id: '', origin: '', destination: '', price: 0);
    }

    return CashoutSummaryModel(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      driver: CashoutDriverModel.fromJson(driverRaw ?? {}),
      taxi: CashoutTaxiModel.fromJson(taxiRaw ?? {}),
      line: line,
      totalSeats: totalSeats,
      totalAmount: totalAmount,
      cashAmount: cashAmount,
      nfcAmount: nfcAmount,
      totalPaid: totalPaid,
      remaining: remaining,
      departedAt: departedRaw != null ? DateTime.tryParse(departedRaw) : null,
    );
  }

  CashoutSummaryEntity toEntity() => CashoutSummaryEntity(
        id: id,
        driver: driver.toEntity(),
        taxi: taxi.toEntity(),
        line: line.toEntity(),
        totalSeats: totalSeats,
        totalAmount: totalAmount,
        cashSeats: cashSeats,
        nfcSeats: nfcSeats,
        cashAmount: cashAmount,
        nfcAmount: nfcAmount,
        totalPaid: totalPaid,
        remaining: remaining,
        departedAt: departedAt,
      );
}

class CashoutsResponseModel {
  final List<CashoutSummaryModel> cashouts;
  final double totalAmount;
  final CashoutStatsModel? stats;

  const CashoutsResponseModel({
    required this.cashouts,
    required this.totalAmount,
    this.stats,
  });

  factory CashoutsResponseModel.fromJson(dynamic json) {
    if (json is List) {
      final items = json
          .map((e) => CashoutSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = items.fold(0.0, (sum, item) => sum + item.totalAmount);
      return CashoutsResponseModel(cashouts: items, totalAmount: total);
    }
    final map = json as Map<String, dynamic>;
    // API returns { status, data: { stats: {...}, driverRows: [...] } }
    final dataMap =
        map['data'] is Map ? map['data'] as Map<String, dynamic> : null;
    final statsMap = dataMap?['stats'] as Map<String, dynamic>?;
    final stats =
        statsMap != null ? CashoutStatsModel.fromJson(statsMap) : null;
    final rawList = (dataMap?['driverRows'] ?? map['cashouts'] ?? []) as List;
    final items = rawList
        .map((e) => CashoutSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final apiTotal = ((statsMap?['totalRemaining'] ??
            statsMap?['totalCollected'] ??
            map['total_amount'] ??
            map['total'] ??
            0) as num)
        .toDouble();
    final total = apiTotal > 0
        ? apiTotal
        : items.fold(0.0, (sum, item) => sum + item.totalAmount);
    return CashoutsResponseModel(cashouts: items, totalAmount: total, stats: stats);
  }

  CashoutsResponseEntity toEntity() => CashoutsResponseEntity(
        cashouts: cashouts.map((e) => e.toEntity()).toList(),
        totalAmount: totalAmount,
        stats: stats?.toEntity(),
      );
}
