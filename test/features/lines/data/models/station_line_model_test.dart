import 'package:cashier/features/lines/data/models/station_line_model.dart';
import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationLineModel', () {
    test('fromJson maps _id key', () {
      final json = {
        '_id': 'l1',
        'origin': 'Casablanca',
        'destination': 'Marrakech',
        'price': 55.0,
        'activeTaxiCount': 3,
      };
      final model = StationLineModel.fromJson(json);
      expect(model.id, 'l1');
      expect(model.origin, 'Casablanca');
      expect(model.destination, 'Marrakech');
      expect(model.price, 55.0);
      expect(model.activeTaxiCount, 3);
    });

    test('fromJson maps id key fallback', () {
      final model = StationLineModel.fromJson({
        'id': 'l2',
        'origin': 'A',
        'destination': 'B',
        'price': 10.0,
        'activeTaxiCount': 0
      });
      expect(model.id, 'l2');
    });

    test('fromJson defaults for missing fields', () {
      final model = StationLineModel.fromJson({});
      expect(model.id, '');
      expect(model.origin, '');
      expect(model.price, 0.0);
      expect(model.activeTaxiCount, 0);
    });

    test('toEntity produces StationLineEntity', () {
      final entity = const StationLineModel(
        id: 'l1',
        origin: 'Casablanca',
        destination: 'Marrakech',
        price: 55.0,
        activeTaxiCount: 3,
      ).toEntity();
      expect(entity, isA<StationLineEntity>());
      expect(entity.id, 'l1');
      expect(entity.price, 55.0);
    });
  });

  group('QueueDriverModel', () {
    test('fromJson maps all fields', () {
      final json = {
        'name': 'Ahmed',
        'phone': '0600',
        'licenseNumber': 'LIC123',
        'permitNumber': 'PERM456',
        'balance': 250.0,
      };
      final model = QueueDriverModel.fromJson(json);
      expect(model.name, 'Ahmed');
      expect(model.phone, '0600');
      expect(model.licenseNumber, 'LIC123');
      expect(model.permitNumber, 'PERM456');
      expect(model.balance, 250.0);
    });

    test('fromJson sets permitNumber to null when absent', () {
      final model = QueueDriverModel.fromJson(
          {'name': 'X', 'phone': '0', 'licenseNumber': 'L', 'balance': 0});
      expect(model.permitNumber, isNull);
    });

    test('toEntity maps correctly', () {
      final entity = const QueueDriverModel(
        name: 'Ahmed',
        phone: '0600',
        licenseNumber: 'LIC',
        balance: 100,
      ).toEntity();
      expect(entity, isA<QueueDriverEntity>());
      expect(entity.name, 'Ahmed');
    });
  });

  group('QueueTaxiModel', () {
    final json = {
      '_id': 't1',
      'plateNumber': 'ABC-123',
      'totalSeats': 6,
      'occupiedSeats': 4,
      'isFirst': true,
      'color': 'white',
      'year': '2020',
      'driver': {
        'name': 'Ahmed',
        'phone': '0600',
        'licenseNumber': 'LIC',
        'balance': 100.0,
      },
    };

    test('fromJson maps all fields', () {
      final model = QueueTaxiModel.fromJson(json);
      expect(model.id, 't1');
      expect(model.plateNumber, 'ABC-123');
      expect(model.totalSeats, 6);
      expect(model.occupiedSeats, 4);
      expect(model.isFirst, isTrue);
      expect(model.color, 'white');
      expect(model.year, '2020');
      expect(model.driver.name, 'Ahmed');
    });

    test('fromJson defaults totalSeats to 6 when absent', () {
      final model = QueueTaxiModel.fromJson({
        '_id': 't2',
        'plateNumber': 'P',
        'isFirst': false,
        'driver': <String, dynamic>{}
      });
      expect(model.totalSeats, 6);
    });

    test('toEntity produces QueueTaxiEntity', () {
      final entity = QueueTaxiModel.fromJson(json).toEntity();
      expect(entity, isA<QueueTaxiEntity>());
      expect(entity.driver.name, 'Ahmed');
    });
  });

  group('QueueTaxiEntity.availableSeats', () {
    test('returns totalSeats minus occupiedSeats', () {
      const entity = QueueTaxiEntity(
        id: 't1',
        plateNumber: 'P1',
        totalSeats: 6,
        occupiedSeats: 2,
        isFirst: false,
        driver: QueueDriverEntity(
          name: 'D',
          phone: '0',
          licenseNumber: 'L',
          balance: 0,
        ),
      );
      expect(entity.availableSeats, 4);
    });

    test('availableSeats is 0 when taxi is full', () {
      const entity = QueueTaxiEntity(
        id: 't2',
        plateNumber: 'P2',
        totalSeats: 6,
        occupiedSeats: 6,
        isFirst: true,
        driver: QueueDriverEntity(
          name: 'D',
          phone: '0',
          licenseNumber: 'L',
          balance: 0,
        ),
      );
      expect(entity.availableSeats, 0);
    });
  });
}
