import 'package:cashier/features/booking/domain/entities/booking_entity.dart';

class TicketModel {
  final String code;
  final int seatNumber;
  final String origin;
  final String destination;
  final double price;
  final String paymentMethod;
  final String plateNumber;
  final String driverName;
  final String? qrData;

  const TicketModel({
    required this.code,
    required this.seatNumber,
    required this.origin,
    required this.destination,
    required this.price,
    required this.paymentMethod,
    required this.plateNumber,
    required this.driverName,
    this.qrData,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json,
          {String fallbackPayment = 'cash'}) =>
      TicketModel(
        code: (json['code'] ?? '') as String,
        seatNumber: (json['seatNumber'] ?? 1) as int,
        origin: (json['origin'] ?? '') as String,
        destination: (json['destination'] ?? '') as String,
        price: ((json['price'] ?? 0) as num).toDouble(),
        paymentMethod: (json['paymentMethod'] ?? fallbackPayment) as String,
        plateNumber: (json['plateNumber'] ?? '') as String,
        driverName: (json['driverName'] ?? '') as String,
        qrData: json['qrData'] as String?,
      );

  TicketEntity toEntity() => TicketEntity(
        code: code,
        seatNumber: seatNumber,
        origin: origin,
        destination: destination,
        price: price,
        paymentMethod: paymentMethod,
        plateNumber: plateNumber,
        driverName: driverName,
        qrData: qrData,
      );
}

class BookingResultModel {
  final String bookingId;
  final String confirmedAt;
  final double? passengerBalanceAfter;
  final TicketModel? ticket;

  const BookingResultModel({
    required this.bookingId,
    required this.confirmedAt,
    this.passengerBalanceAfter,
    this.ticket,
  });

  factory BookingResultModel.fromJson(Map<String, dynamic> json,
      {String fallbackPayment = 'cash'}) {
    final t = json['ticket'] as Map<String, dynamic>?;
    return BookingResultModel(
      bookingId:
          (json['bookingId'] ?? json['_id'] ?? json['id'] ?? '') as String,
      confirmedAt: (json['confirmedAt'] ?? '') as String,
      passengerBalanceAfter: json['passengerBalanceAfter'] != null
          ? (json['passengerBalanceAfter'] as num).toDouble()
          : null,
      ticket: t != null
          ? TicketModel.fromJson(t, fallbackPayment: fallbackPayment)
          : null,
    );
  }

  BookingResultEntity toEntity() => BookingResultEntity(
        bookingId: bookingId,
        confirmedAt: confirmedAt,
        passengerBalanceAfter: passengerBalanceAfter,
        ticket: ticket?.toEntity(),
      );
}
