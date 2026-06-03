import 'package:cashier/features/passengers/data/models/passenger_model.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PassengerTripModel', () {
    test('fromJson when line is a Map uses origin/destination', () {
      final json = {
        'line': {'origin': 'Fes', 'destination': 'Meknes'},
      };
      final model = PassengerTripModel.fromJson(json);
      expect(model.from, 'Fes');
      expect(model.to, 'Meknes');
    });

    test('fromJson when line is a String with em-dash and → separator', () {
      final json = {'line': 'Ticket 1 — Bab doukkala → Mhamid'};
      final model = PassengerTripModel.fromJson(json);
      expect(model.from, 'Bab doukkala');
      expect(model.to, 'Mhamid');
    });

    test('fromJson when line is a String with only → separator', () {
      final json = {'line': 'Casablanca → Agadir'};
      final model = PassengerTripModel.fromJson(json);
      expect(model.from, 'Casablanca');
      expect(model.to, 'Agadir');
    });

    test('fromJson when line is a String with no separator uses full string as from', () {
      final json = {'line': 'Marrakech'};
      final model = PassengerTripModel.fromJson(json);
      expect(model.from, 'Marrakech');
      expect(model.to, '');
    });

    test('fromJson when no line field falls back to from/to', () {
      final json = {'from': 'Oujda', 'to': 'Berkane'};
      final model = PassengerTripModel.fromJson(json);
      expect(model.from, 'Oujda');
      expect(model.to, 'Berkane');
    });

    test('toEntity maps correctly', () {
      final entity = PassengerTripModel(from: 'A', to: 'B').toEntity();
      expect(entity, isA<PassengerTripEntity>());
      expect(entity.from, 'A');
    });
  });

  group('PassengerModel', () {
    final json = {
      '_id': 'p1',
      'name': 'Fatima',
      'phone': '0600000001',
      'balance': 150.0,
      'recentTrips': [
        {'line': {'origin': 'Fes', 'destination': 'Rabat'}},
        {'line': 'Casablanca → Marrakech'},
      ],
    };

    test('fromJson maps all fields including recentTrips', () {
      final model = PassengerModel.fromJson(json);
      expect(model.id, 'p1');
      expect(model.name, 'Fatima');
      expect(model.phone, '0600000001');
      expect(model.balance, 150.0);
      expect(model.recentTrips.length, 2);
      expect(model.recentTrips[0].from, 'Fes');
      expect(model.recentTrips[1].from, 'Casablanca');
    });

    test('fromJson maps id fallback key', () {
      final model = PassengerModel.fromJson({'id': 'p2', 'name': 'X', 'phone': '0', 'balance': 0});
      expect(model.id, 'p2');
    });

    test('fromJson with empty recentTrips', () {
      final model = PassengerModel.fromJson({'_id': 'p3', 'name': 'X', 'phone': '0', 'balance': 0});
      expect(model.recentTrips, isEmpty);
    });

    test('toEntity produces PassengerEntity', () {
      final entity = PassengerModel.fromJson(json).toEntity();
      expect(entity, isA<PassengerEntity>());
      expect(entity.name, 'Fatima');
      expect(entity.recentTrips.length, 2);
    });
  });

  group('NfcTopupResult.fromJson', () {
    test('maps all fields', () {
      final json = {
        'id': 'top1',
        'name': 'Ali',
        'phone': '0600',
        'nfcTagId': 'NFC123',
        'balanceBefore': 100.0,
        'balanceAfter': 150.0,
        'amount': 50.0,
      };
      final result = NfcTopupResult.fromJson(json);
      expect(result.id, 'top1');
      expect(result.balanceBefore, 100.0);
      expect(result.balanceAfter, 150.0);
      expect(result.amount, 50.0);
    });

    test('defaults to 0 for missing numeric fields', () {
      final result = NfcTopupResult.fromJson({});
      expect(result.balanceBefore, 0.0);
      expect(result.amount, 0.0);
    });
  });

  group('RechargeParams.toJson', () {
    test('includes nfcTagId when provided', () {
      const params = RechargeParams(nfcTagId: 'NFC123', amount: 50.0);
      final json = params.toJson();
      expect(json['nfcTagId'], 'NFC123');
      expect(json['amount'], 50.0);
      expect(json.containsKey('phone'), isFalse);
    });

    test('includes phone when provided', () {
      const params = RechargeParams(phone: '0600000001', amount: 100.0);
      final json = params.toJson();
      expect(json['phone'], '0600000001');
      expect(json.containsKey('nfcTagId'), isFalse);
    });
  });

  group('LinkNfcParams.toJson', () {
    test('includes all fields', () {
      const params = LinkNfcParams(phone: '0600', nfcTagId: 'NFC1', name: 'Ali');
      final json = params.toJson();
      expect(json['phone'], '0600');
      expect(json['nfcTagId'], 'NFC1');
      expect(json['name'], 'Ali');
    });

    test('uses empty string when name is null', () {
      const params = LinkNfcParams(phone: '0600', nfcTagId: 'NFC1');
      expect(params.toJson()['name'], '');
    });
  });

  group('NfcTopupParams.toJson', () {
    test('includes amount and note when provided', () {
      const params = NfcTopupParams(nfcTagId: 'NFC1', amount: 50.0, note: 'recharge');
      final json = params.toJson();
      expect(json['amount'], 50.0);
      expect(json['note'], 'recharge');
    });

    test('excludes note when absent', () {
      const params = NfcTopupParams(nfcTagId: 'NFC1', amount: 50.0);
      expect(params.toJson().containsKey('note'), isFalse);
    });
  });

  group('PhoneTopupParams.toJson', () {
    test('includes note when provided', () {
      const params = PhoneTopupParams(phone: '0600', amount: 100.0, note: 'gift');
      final json = params.toJson();
      expect(json['amount'], 100.0);
      expect(json['note'], 'gift');
    });

    test('excludes note when absent', () {
      const params = PhoneTopupParams(phone: '0600', amount: 100.0);
      expect(params.toJson().containsKey('note'), isFalse);
    });
  });
}
