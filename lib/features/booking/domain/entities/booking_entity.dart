class CreateBookingParams {
  final String stationId;
  final String lineId;
  final int seatCount;
  final String paymentMethod; // 'cash' | 'nfc'
  final String? nfcTagId;
  final String? passengerId;
  final int? seatNumber;

  const CreateBookingParams({
    required this.stationId,
    required this.lineId,
    required this.seatCount,
    required this.paymentMethod,
    this.nfcTagId,
    this.passengerId,
    this.seatNumber,
  });

  Map<String, dynamic> toJson() => {
        'stationId': stationId,
        'lineId': lineId,
        'seatCount': seatCount,
        'paymentMethod': paymentMethod,
        if (nfcTagId != null) 'nfcTagId': nfcTagId,
        if (passengerId != null) 'passengerId': passengerId,
        if (seatNumber != null) 'seatNumber': seatNumber,
      };
}

class BookingResultEntity {
  final String id;
  final int seatCount;
  final double amount;
  final String paymentMethod;

  const BookingResultEntity({
    required this.id,
    required this.seatCount,
    required this.amount,
    required this.paymentMethod,
  });
}
