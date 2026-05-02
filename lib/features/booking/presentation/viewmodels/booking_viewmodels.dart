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

  TaxiInfo copyWith({int? occupiedSeats}) => TaxiInfo(
        id: id,
        plateNumber: plateNumber,
        totalSeats: totalSeats,
        occupiedSeats: occupiedSeats ?? this.occupiedSeats,
        status: status,
        driver: driver,
        color: color,
        year: year,
        isFirst: isFirst,
      );
}
