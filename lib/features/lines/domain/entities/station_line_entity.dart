class StationLineEntity {
  final String id;
  final String origin;
  final String destination;
  final double price;
  final int activeTaxiCount;

  const StationLineEntity({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    required this.activeTaxiCount,
  });
}

class QueueDriverEntity {
  final String name;
  final String phone;
  final String licenseNumber;
  final String? permitNumber;
  final double balance;

  const QueueDriverEntity({
    required this.name,
    required this.phone,
    required this.licenseNumber,
    this.permitNumber,
    required this.balance,
  });
}

class QueueTaxiEntity {
  final String id;
  final String plateNumber;
  final int totalSeats;
  final int occupiedSeats;
  final bool isFirst;
  final String? color;
  final String? year;
  final QueueDriverEntity driver;

  const QueueTaxiEntity({
    required this.id,
    required this.plateNumber,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.isFirst,
    this.color,
    this.year,
    required this.driver,
  });

  int get availableSeats => totalSeats - occupiedSeats;
}
