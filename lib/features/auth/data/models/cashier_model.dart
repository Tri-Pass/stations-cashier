import 'package:cashier/features/auth/domain/entities/driver_entity.dart';

class StationModel {
  final String id;
  final String name;
  final String? code;
  final String? city;

  const StationModel({
    required this.id,
    required this.name,
    this.code,
    this.city,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
        id: (json['_id'] ?? json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        code: json['code'] as String?,
        city: json['city'] as String?,
      );

  StationEntity toEntity() => StationEntity(
        id: id,
        name: name,
        code: code,
        city: city,
      );
}

class CashierModel {
  final String id;
  final String name;
  final String phone;
  final StationModel? station;

  const CashierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.station,
  });

  factory CashierModel.fromJson(Map<String, dynamic> json) {
    StationModel? station;
    if (json['station'] is Map<String, dynamic>) {
      station = StationModel.fromJson(json['station'] as Map<String, dynamic>);
    }
    return CashierModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      station: station,
    );
  }

  DriverEntity toEntity() => DriverEntity(
        id: id,
        name: name,
        phone: phone,
        taxiNumber: '',
        plateNumber: '',
        balance: 0,
        station: station?.toEntity(),
      );
}
