import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationEntity', () {
    test('props contains only id — equal when ids match despite different names', () {
      const s1 = StationEntity(id: 's1', name: 'Gare', code: 'G1', city: 'Casa');
      const s2 = StationEntity(id: 's1', name: 'Other Name');
      expect(s1, equals(s2));
      expect(s1.props, ['s1']);
    });

    test('not equal when ids differ', () {
      const s1 = StationEntity(id: 's1', name: 'Gare');
      const s2 = StationEntity(id: 's2', name: 'Gare');
      expect(s1, isNot(equals(s2)));
    });
  });

  group('LineEntity', () {
    const line = LineEntity(
      id: 'l1',
      origin: 'Casablanca',
      destination: 'Marrakech',
      price: 55.0,
    );

    test('display formats as "origin → destination"', () {
      expect(line.display, 'Casablanca → Marrakech');
    });

    test('props contains only id', () {
      expect(line.props, ['l1']);
    });

    test('equal when ids match regardless of other fields', () {
      const same = LineEntity(id: 'l1', origin: 'X', destination: 'Y', price: 0);
      expect(line, equals(same));
    });

    test('not equal when ids differ', () {
      const other = LineEntity(id: 'l2', origin: 'Casablanca', destination: 'Marrakech', price: 55.0);
      expect(line, isNot(equals(other)));
    });
  });

  group('DriverEntity', () {
    const driver = DriverEntity(
      id: 'd1',
      name: 'Ahmed',
      phone: '0600',
      taxiNumber: 'T1',
      plateNumber: 'P1',
      balance: 100.0,
    );

    test('props contains only id', () {
      expect(driver.props, ['d1']);
    });

    test('equal when ids match', () {
      const same = DriverEntity(
        id: 'd1',
        name: 'Different',
        phone: '0611',
        taxiNumber: 'T9',
        plateNumber: 'P9',
        balance: 0,
      );
      expect(driver, equals(same));
    });
  });
}
