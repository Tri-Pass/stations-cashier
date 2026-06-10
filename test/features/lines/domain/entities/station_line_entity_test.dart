import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationLineEntity', () {
    const entity = StationLineEntity(
      id: 'line-1',
      origin: 'Marrakech',
      destination: 'Casablanca',
      price: 80.0,
      activeTaxiCount: 3,
    );

    test('holds all fields', () {
      expect(entity.id, 'line-1');
      expect(entity.origin, 'Marrakech');
      expect(entity.destination, 'Casablanca');
      expect(entity.price, 80.0);
      expect(entity.activeTaxiCount, 3);
    });
  });

  group('QueueTaxiEntity', () {
    const driver = QueueDriverEntity(
      name: 'Youssef',
      phone: '0612345678',
      licenseNumber: 'LIC-001',
      balance: 200.0,
    );

    const taxi = QueueTaxiEntity(
      id: 'taxi-1',
      plateNumber: 'A-001-MA',
      totalSeats: 6,
      occupiedSeats: 4,
      isFirst: true,
      driver: driver,
    );

    test('availableSeats = totalSeats - occupiedSeats', () {
      expect(taxi.availableSeats, 2);
    });

    test('isFirst flag is stored', () {
      expect(taxi.isFirst, isTrue);
    });

    test('optional fields default to null', () {
      expect(taxi.color, isNull);
      expect(taxi.year, isNull);
      expect(driver.permitNumber, isNull);
    });
  });
}
