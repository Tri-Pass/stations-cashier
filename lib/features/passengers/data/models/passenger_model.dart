import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';

class PassengerTripModel {
  final String from;
  final String to;

  const PassengerTripModel({required this.from, required this.to});

  factory PassengerTripModel.fromJson(Map<String, dynamic> json) {
    final raw = json['line'];

    // Case 1: line is a Map { origin, destination }
    if (raw is Map<String, dynamic>) {
      return PassengerTripModel(
        from: (raw['origin'] ?? '') as String,
        to: (raw['destination'] ?? '') as String,
      );
    }

    // Case 2: line is a String e.g. "Ticket X — Bab doukkala → Mhamid"
    if (raw is String) {
      // Try to extract "origin → destination" after the em-dash separator
      final afterDash = raw.contains(' — ') ? raw.split(' — ').last : raw;
      final parts = afterDash.split(' → ');
      return PassengerTripModel(
        from: parts.isNotEmpty ? parts.first.trim() : raw,
        to: parts.length > 1 ? parts.last.trim() : '',
      );
    }

    // Case 3: no line field — fall back to from/to
    return PassengerTripModel(
      from: (json['from'] ?? '') as String,
      to: (json['to'] ?? '') as String,
    );
  }

  PassengerTripEntity toEntity() => PassengerTripEntity(from: from, to: to);
}

class PassengerModel {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final List<PassengerTripModel> recentTrips;

  const PassengerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    this.recentTrips = const [],
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    final tripsRaw = json['recentTrips'] as List<dynamic>? ?? [];
    return PassengerModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      balance: ((json['balance'] ?? 0) as num).toDouble(),
      recentTrips: tripsRaw
          .map((t) => PassengerTripModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  PassengerEntity toEntity() => PassengerEntity(
        id: id,
        name: name,
        phone: phone,
        balance: balance,
        recentTrips: recentTrips.map((t) => t.toEntity()).toList(),
      );
}
