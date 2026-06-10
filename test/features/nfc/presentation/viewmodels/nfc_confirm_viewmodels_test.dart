import 'package:cashier/features/nfc/presentation/viewmodels/nfc_confirm_viewmodels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NfcClientInfo', () {
    test('holds all fields', () {
      const trip = NfcTripInfo(from: 'Agadir', to: 'Marrakech');
      const client = NfcClientInfo(
        id: 'c1',
        name: 'Sara',
        phone: '0600000000',
        balance: 120.5,
        trips: [trip],
      );
      expect(client.id, 'c1');
      expect(client.balance, 120.5);
      expect(client.trips.first.from, 'Agadir');
    });
  });

  group('NfcLineInfo', () {
    test('holds all fields', () {
      const line = NfcLineInfo(
        id: 'l1',
        origin: 'Marrakech',
        destination: 'Casablanca',
        price: 80,
      );
      expect(line.destination, 'Casablanca');
      expect(line.price, 80);
    });
  });

  group('NfcTripInfo', () {
    test('stores from/to', () {
      const t = NfcTripInfo(from: 'A', to: 'B');
      expect(t.from, 'A');
      expect(t.to, 'B');
    });
  });
}
