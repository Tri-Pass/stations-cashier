import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';

class StationLineModel {
  final String id;
  final String origin;
  final String destination;
  final double price;
  final int activeTaxiCount;

  const StationLineModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    required this.activeTaxiCount,
  });

  factory StationLineModel.fromJson(Map<String, dynamic> json) =>
      StationLineModel(
        id: (json['_id'] ?? json['id'] ?? '') as String,
        origin: (json['origin'] ?? '') as String,
        destination: (json['destination'] ?? '') as String,
        price: ((json['price'] ?? 0) as num).toDouble(),
        activeTaxiCount: (json['activeTaxiCount'] ?? 0) as int,
      );

  StationLineEntity toEntity() => StationLineEntity(
        id: id,
        origin: origin,
        destination: destination,
        price: price,
        activeTaxiCount: activeTaxiCount,
      );
}

class QueueDriverModel {
  final String name;
  final String phone;
  final String licenseNumber;
  final String? permitNumber;
  final double balance;

  const QueueDriverModel({
    required this.name,
    required this.phone,
    required this.licenseNumber,
    this.permitNumber,
    required this.balance,
  });

  factory QueueDriverModel.fromJson(Map<String, dynamic> json) =>
      QueueDriverModel(
        name: (json['name'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        licenseNumber: (json['licenseNumber'] ?? '') as String,
        permitNumber: json['permitNumber'] as String?,
        balance: ((json['balance'] ?? 0) as num).toDouble(),
      );

  QueueDriverEntity toEntity() => QueueDriverEntity(
        name: name,
        phone: phone,
        licenseNumber: licenseNumber,
        permitNumber: permitNumber,
        balance: balance,
      );
}

class QueueTaxiModel {
  final String id;
  final String plateNumber;
  final int totalSeats;
  final int occupiedSeats;
  final bool isFirst;
  final String? color;
  final String? year;
  final QueueDriverModel driver;

  const QueueTaxiModel({
    required this.id,
    required this.plateNumber,
    required this.totalSeats,
    required this.occupiedSeats,
    required this.isFirst,
    this.color,
    this.year,
    required this.driver,
  });

  factory QueueTaxiModel.fromJson(Map<String, dynamic> json) {
    final driverJson = json['driver'] as Map<String, dynamic>? ?? {};
    return QueueTaxiModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      plateNumber: (json['plateNumber'] ?? '') as String,
      totalSeats: (json['totalSeats'] ?? 6) as int,
      occupiedSeats: (json['occupiedSeats'] ?? 0) as int,
      isFirst: (json['isFirst'] ?? false) as bool,
      color: json['color'] as String?,
      year: json['year'] as String?,
      driver: QueueDriverModel.fromJson(driverJson),
    );
  }

  QueueTaxiEntity toEntity() => QueueTaxiEntity(
        id: id,
        plateNumber: plateNumber,
        totalSeats: totalSeats,
        occupiedSeats: occupiedSeats,
        isFirst: isFirst,
        color: color,
        year: year,
        driver: driver.toEntity(),
      );
}
