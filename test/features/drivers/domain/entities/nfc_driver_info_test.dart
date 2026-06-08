import 'package:cashier/features/drivers/domain/entities/nfc_driver_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NfcDriverInfo.fromJson', () {
    test('parses all fields from json using _id', () {
      final json = {
        '_id': 'd1',
        'name': 'Ahmed',
        'taxiNumber': 'T1',
        'phone': '0600',
        'destination': 'Rabat',
        'seatsTotal': 6,
        'alreadyQueued': false,
      };

      final info = NfcDriverInfo.fromJson(json);

      expect(info.id, 'd1');
      expect(info.name, 'Ahmed');
      expect(info.taxiNumber, 'T1');
      expect(info.phone, '0600');
      expect(info.destination, 'Rabat');
      expect(info.seatsTotal, 6);
      expect(info.alreadyQueued, isFalse);
    });

    test('parses id fallback from id field', () {
      final json = {
        'id': 'd2',
        'name': 'Hassan',
        'taxiNumber': 'T2',
        'phone': '0601',
        'destination': 'Casa',
        'seatsTotal': 4,
      };

      final info = NfcDriverInfo.fromJson(json);

      expect(info.id, 'd2');
      expect(info.seatsTotal, 4);
      expect(info.alreadyQueued, isFalse);
    });

    test('defaults seatsTotal to 6 when missing', () {
      final info = NfcDriverInfo.fromJson({});
      expect(info.seatsTotal, 6);
    });

    test('parses alreadyQueued as true', () {
      final info = NfcDriverInfo.fromJson({'alreadyQueued': true});
      expect(info.alreadyQueued, isTrue);
    });

    test('defaults empty strings when fields missing', () {
      final info = NfcDriverInfo.fromJson({});
      expect(info.id, '');
      expect(info.name, '');
      expect(info.taxiNumber, '');
      expect(info.phone, '');
      expect(info.destination, '');
    });
  });
}
