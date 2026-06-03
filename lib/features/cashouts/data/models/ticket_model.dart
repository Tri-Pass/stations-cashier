import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';

class TicketLineModel {
  final String id;
  final String origin;
  final String destination;
  final double price;

  const TicketLineModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });

  factory TicketLineModel.fromJson(Map<String, dynamic> j) => TicketLineModel(
        id: (j['id'] ?? j['_id'] ?? '') as String,
        origin: (j['origin'] ?? '') as String,
        destination: (j['destination'] ?? '') as String,
        price: ((j['price'] ?? 0) as num).toDouble(),
      );

  TicketLineEntity toEntity() => TicketLineEntity(
      id: id, origin: origin, destination: destination, price: price);
}

class TicketModel {
  final String id;
  final TicketLineModel line;
  final int totalSeats;
  final String paidMethod;
  final double amount;
  final DateTime? departedAt;
  final String status;

  const TicketModel({
    required this.id,
    required this.line,
    required this.totalSeats,
    required this.paidMethod,
    required this.amount,
    required this.status,
    this.departedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> j) {
    final lineRaw = j['line'] as Map<String, dynamic>? ?? {};
    final departedRaw = (j['departedAt'] ?? j['departed_at']) as String?;
    return TicketModel(
      id: (j['id'] ?? j['_id'] ?? '') as String,
      line: TicketLineModel.fromJson(lineRaw),
      totalSeats: ((j['totalSeats'] ?? j['total_seats'] ?? 1) as num).toInt(),
      paidMethod: (j['paidMethod'] ?? j['paid_method'] ?? 'cash') as String,
      amount: ((j['amount'] ?? 0) as num).toDouble(),
      departedAt: departedRaw != null ? DateTime.tryParse(departedRaw) : null,
      status: (j['status'] ?? 'unpaid') as String,
    );
  }

  TicketEntity toEntity() => TicketEntity(
        id: id,
        line: line.toEntity(),
        totalSeats: totalSeats,
        paidMethod: paidMethod,
        amount: amount,
        departedAt: departedAt,
        status: status,
      );
}

class DriverInfoModel {
  final String id;
  final String name;
  final String phone;

  const DriverInfoModel(
      {required this.id, required this.name, required this.phone});

  factory DriverInfoModel.fromJson(Map<String, dynamic> j) => DriverInfoModel(
        id: (j['id'] ?? j['_id'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
      );

  DriverInfoEntity toEntity() =>
      DriverInfoEntity(id: id, name: name, phone: phone);
}

class TicketsSummaryModel {
  final int totalTickets;
  final double totalCashAmount;
  final double totalNfcAmount;
  final double totalAmount;

  const TicketsSummaryModel({
    required this.totalTickets,
    required this.totalCashAmount,
    required this.totalNfcAmount,
    required this.totalAmount,
  });

  factory TicketsSummaryModel.fromJson(Map<String, dynamic> j) =>
      TicketsSummaryModel(
        totalTickets: ((j['totalTickets'] ?? 0) as num).toInt(),
        totalCashAmount: ((j['totalCashAmount'] ?? 0) as num).toDouble(),
        totalNfcAmount: ((j['totalNfcAmount'] ?? 0) as num).toDouble(),
        totalAmount: ((j['totalAmount'] ?? 0) as num).toDouble(),
      );

  TicketsSummaryEntity toEntity() => TicketsSummaryEntity(
        totalTickets: totalTickets,
        totalCashAmount: totalCashAmount,
        totalNfcAmount: totalNfcAmount,
        totalAmount: totalAmount,
      );
}

class DriverTicketsModel {
  final DriverInfoModel driver;
  final List<TicketModel> tickets;
  final TicketsSummaryModel summary;

  const DriverTicketsModel({
    required this.driver,
    required this.tickets,
    required this.summary,
  });

  factory DriverTicketsModel.fromJson(dynamic raw) {
    final Map<String, dynamic> data = raw is Map && raw['data'] is Map
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;

    final driverRaw = data['driver'] as Map<String, dynamic>? ?? {};
    final ticketsRaw = (data['tickets'] as List?) ?? [];
    final summaryRaw = data['summary'] as Map<String, dynamic>? ?? {};

    return DriverTicketsModel(
      driver: DriverInfoModel.fromJson(driverRaw),
      tickets: ticketsRaw
          .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: TicketsSummaryModel.fromJson(summaryRaw),
    );
  }

  DriverTicketsEntity toEntity() => DriverTicketsEntity(
        driver: driver.toEntity(),
        tickets: tickets.map((t) => t.toEntity()).toList(),
        summary: summary.toEntity(),
      );
}
