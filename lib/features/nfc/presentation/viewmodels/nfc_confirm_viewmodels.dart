class NfcClientInfo {
  final String id;
  final String name;
  final String phone;
  final double balance;
  final List<NfcTripInfo> trips;

  const NfcClientInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.trips,
  });
}

class NfcTripInfo {
  final String from;
  final String to;
  const NfcTripInfo({required this.from, required this.to});
}

class NfcLineInfo {
  final String id;
  final String origin;
  final String destination;
  final int price;

  const NfcLineInfo({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
  });
}
