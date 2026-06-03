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

class RechargeParams {
  final String? nfcTagId;
  final String? phone;
  final double amount;

  const RechargeParams({this.nfcTagId, this.phone, required this.amount})
      : assert(nfcTagId != null || phone != null,
            'Either nfcTagId or phone must be provided');

  Map<String, dynamic> toJson() => {
        if (nfcTagId != null) 'nfcTagId': nfcTagId,
        if (phone != null) 'phone': phone,
        'amount': amount,
      };
}

class PhoneTopupParams {
  final String phone;
  final double amount;
  final String? note;

  const PhoneTopupParams({
    required this.phone,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (note != null) 'note': note,
      };
}

class NfcTopupParams {
  final String nfcTagId;
  final double amount;
  final String? note;

  const NfcTopupParams({
    required this.nfcTagId,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (note != null) 'note': note,
      };
}

class NfcTopupResult {
  final String id;
  final String name;
  final String phone;
  final String nfcTagId;
  final double balanceBefore;
  final double balanceAfter;
  final double amount;

  const NfcTopupResult({
    required this.id,
    required this.name,
    required this.phone,
    required this.nfcTagId,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.amount,
  });

  factory NfcTopupResult.fromJson(Map<String, dynamic> json) => NfcTopupResult(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        nfcTagId: (json['nfcTagId'] ?? '') as String,
        balanceBefore: ((json['balanceBefore'] ?? 0) as num).toDouble(),
        balanceAfter: ((json['balanceAfter'] ?? 0) as num).toDouble(),
        amount: ((json['amount'] ?? 0) as num).toDouble(),
      );
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
        'name': name ?? "",
      };
}
