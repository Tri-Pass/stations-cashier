class CashoutDriverEntity {
  final String id;
  final String name;
  final String phone;
  const CashoutDriverEntity(
      {required this.id, required this.name, required this.phone});
}

class CashoutTaxiEntity {
  final String id;
  final String plateNumber;
  const CashoutTaxiEntity({required this.id, required this.plateNumber});
}

class CashoutLineEntity {
  final String id;
  final String origin;
  final String destination;
  final double price;
  const CashoutLineEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });
}

class CashoutStatsEntity {
  final int totalTickets;
  final double totalCollected;
  final double totalNfc;
  final double totalCash;
  final double totalPayouts;
  final double totalRemaining;

  const CashoutStatsEntity({
    required this.totalTickets,
    required this.totalCollected,
    required this.totalNfc,
    required this.totalCash,
    required this.totalPayouts,
    required this.totalRemaining,
  });
}

class CashoutSummaryEntity {
  final String id;
  final CashoutDriverEntity driver;
  final CashoutTaxiEntity taxi;
  final CashoutLineEntity line;
  final int totalSeats;
  final double totalAmount;
  final int cashSeats;
  final int nfcSeats;
  final double cashAmount;
  final double nfcAmount;
  final double totalPaid;
  final double remaining;
  final DateTime? departedAt;

  const CashoutSummaryEntity({
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
}

class CashoutsResponseEntity {
  final List<CashoutSummaryEntity> cashouts;
  final double totalAmount;
  final CashoutStatsEntity? stats;

  const CashoutsResponseEntity({
    required this.cashouts,
    required this.totalAmount,
    this.stats,
  });
}
