import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PassengerEntity', () {
    test('defaults to empty trips list', () {
      const p = PassengerEntity(
        id: 'p1',
        name: 'Fatima',
        phone: '0601020304',
        balance: 120.0,
      );
      expect(p.recentTrips, isEmpty);
    });

    test('holds all fields including trips', () {
      const trip = PassengerTripEntity(from: 'Agadir', to: 'Marrakech');
      const p = PassengerEntity(
        id: 'p2',
        name: 'Ali',
        phone: '0699887766',
        balance: 50.5,
        recentTrips: [trip],
      );
      expect(p.recentTrips.length, 1);
      expect(p.recentTrips.first.from, 'Agadir');
      expect(p.recentTrips.first.to, 'Marrakech');
    });
  });

  group('NfcTopupParams', () {
    test('toJson excludes null note', () {
      const p = NfcTopupParams(nfcTagId: 'tag-1', amount: 100.0);
      final json = p.toJson();
      expect(json['amount'], 100.0);
      expect(json.containsKey('note'), isFalse);
    });
  });

  group('LinkNfcParams', () {
    test('toJson maps phone and tagId', () {
      const p = LinkNfcParams(phone: '0600000000', nfcTagId: 'tag-abc');
      final json = p.toJson();
      expect(json['phone'], '0600000000');
      expect(json['nfcTagId'], 'tag-abc');
    });
  });

  group('NfcTopupResult', () {
    test('fromJson parses all fields', () {
      final r = NfcTopupResult.fromJson({
        'id': 'r1',
        'name': 'Sara',
        'phone': '0600000001',
        'nfcTagId': 'nfc-x',
        'balanceBefore': 100.0,
        'balanceAfter': 200.0,
        'amount': 100.0,
      });
      expect(r.name, 'Sara');
      expect(r.balanceAfter, 200.0);
    });
  });
}
