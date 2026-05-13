class TicketLineEntity {
  final String id;
  final String origin;
  final String destination;
  final double price;
  const TicketLineEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });
}

class TicketEntity {
  final String id;
  final TicketLineEntity line;
  final int totalSeats;
  final String paidMethod; // 'cash' | 'nfc'
  final double amount;
  final DateTime? departedAt;
  final String status; // 'paid' | 'unpaid'

  const TicketEntity({
    required this.id,
    required this.line,
    required this.totalSeats,
    required this.paidMethod,
    required this.amount,
    required this.status,
    this.departedAt,
  });

  bool get isCash => paidMethod == 'cash';
  bool get isUnpaid => status == 'unpaid';

  TicketEntity copyWith({String? status}) => TicketEntity(
        id: id,
        line: line,
        totalSeats: totalSeats,
        paidMethod: paidMethod,
        amount: amount,
        departedAt: departedAt,
        status: status ?? this.status,
      );
}

class TicketsSummaryEntity {
  final int totalTickets;
  final double totalCashAmount;
  final double totalNfcAmount;
  final double totalAmount;
  const TicketsSummaryEntity({
    required this.totalTickets,
    required this.totalCashAmount,
    required this.totalNfcAmount,
    required this.totalAmount,
  });
}

class DriverInfoEntity {
  final String id;
  final String name;
  final String phone;
  const DriverInfoEntity({
    required this.id,
    required this.name,
    required this.phone,
  });
}

class DriverTicketsEntity {
  final DriverInfoEntity driver;
  final List<TicketEntity> tickets;
  final TicketsSummaryEntity summary;
  const DriverTicketsEntity({
    required this.driver,
    required this.tickets,
    required this.summary,
  });
}

class CashoutResultEntity {
  final double totalAmountCashedOut;
  const CashoutResultEntity(this.totalAmountCashedOut);
}
