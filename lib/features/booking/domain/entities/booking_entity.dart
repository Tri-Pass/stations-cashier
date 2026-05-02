class CreateBookingParams {
  final String taxiId;
  final String lineId;
  final int seatCount;
  final String paymentMethod; // 'cash' | 'nfc'
  final String cashierId;
  final String? nfcTagId;

  const CreateBookingParams({
    required this.taxiId,
    required this.lineId,
    required this.seatCount,
    required this.paymentMethod,
    required this.cashierId,
    this.nfcTagId,
  });

  Map<String, dynamic> toJson() => {
        'taxiId': taxiId,
        'lineId': lineId,
        'seatCount': seatCount,
        'paymentMethod': paymentMethod,
        'cashierId': cashierId,
        if (nfcTagId != null) 'nfcTagId': nfcTagId,
      };
}

class TicketEntity {
  final String code;
  final int seatNumber;
  final String origin;
  final String destination;
  final double price;
  final String paymentMethod;
  final String plateNumber;
  final String driverName;
  final String? qrData; // data:image/png;base64,...

  const TicketEntity({
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
}

class BookingResultEntity {
  final String bookingId;
  final String confirmedAt;
  final double? passengerBalanceAfter;
  final TicketEntity? ticket;

  const BookingResultEntity({
    required this.bookingId,
    required this.confirmedAt,
    this.passengerBalanceAfter,
    this.ticket,
  });
}
