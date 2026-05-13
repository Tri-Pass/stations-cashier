class NfcDriverInfo {
  final String id;
  final String name;
  final String taxiNumber;
  final String phone;
  final String destination;
  final int seatsTotal;
  final bool alreadyQueued;

  const NfcDriverInfo({
    required this.id,
    required this.name,
    required this.taxiNumber,
    required this.phone,
    required this.destination,
    required this.seatsTotal,
    this.alreadyQueued = false,
  });

  factory NfcDriverInfo.fromJson(Map<String, dynamic> j) => NfcDriverInfo(
        id: (j['_id'] ?? j['id'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        taxiNumber: (j['taxiNumber'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        destination: (j['destination'] ?? '') as String,
        seatsTotal: (j['seatsTotal'] as num?)?.toInt() ?? 6,
        alreadyQueued: (j['alreadyQueued'] as bool?) ?? false,
      );
}
