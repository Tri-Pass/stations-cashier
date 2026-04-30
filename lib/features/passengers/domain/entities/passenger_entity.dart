class PassengerTripEntity {
  final String from;
  final String to;
  const PassengerTripEntity({required this.from, required this.to});
}

class PassengerEntity {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final List<PassengerTripEntity> recentTrips;

  const PassengerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    this.recentTrips = const [],
  });
}

class LinkNfcParams {
  final String phone;
  final String nfcTagId;
  final String? name;

  const LinkNfcParams({
    required this.phone,
    required this.nfcTagId,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'nfcTagId': nfcTagId,
        if (name != null) 'name': name,
      };
}
