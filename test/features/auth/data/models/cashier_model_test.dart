import 'package:cashier/features/auth/data/models/cashier_model.dart';
import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationModel', () {
    test('fromJson maps _id key', () {
      final json = {
        '_id': 's1',
        'name': 'Gare',
        'code': 'G1',
        'city': 'Casablanca'
      };
      final model = StationModel.fromJson(json);
      expect(model.id, 's1');
      expect(model.name, 'Gare');
      expect(model.code, 'G1');
      expect(model.city, 'Casablanca');
    });

    test('fromJson maps id key when _id is absent', () {
      final json = {'id': 's2', 'name': 'Terminal'};
      final model = StationModel.fromJson(json);
      expect(model.id, 's2');
    });

    test('fromJson defaults to empty string when no id present', () {
      final model = StationModel.fromJson({'name': 'X'});
      expect(model.id, '');
    });

    test('fromJson has null optional fields', () {
      final model = StationModel.fromJson({'_id': 's3', 'name': 'Y'});
      expect(model.code, isNull);
      expect(model.city, isNull);
    });

    test('toEntity produces StationEntity with same values', () {
      const model =
          StationModel(id: 's1', name: 'Gare', code: 'G1', city: 'Casa');
      final entity = model.toEntity();
      expect(entity, isA<StationEntity>());
      expect(entity.id, 's1');
      expect(entity.name, 'Gare');
      expect(entity.code, 'G1');
      expect(entity.city, 'Casa');
    });
  });

  group('CashierModel', () {
    test('fromJson maps _id and nested station', () {
      final json = {
        '_id': 'c1',
        'name': 'Ahmed',
        'phone': '0600000001',
        'station': {'_id': 's1', 'name': 'Gare', 'code': 'G1'},
      };
      final model = CashierModel.fromJson(json);
      expect(model.id, 'c1');
      expect(model.name, 'Ahmed');
      expect(model.phone, '0600000001');
      expect(model.station, isNotNull);
      expect(model.station!.id, 's1');
    });

    test('fromJson uses id key fallback', () {
      final json = {'id': 'c2', 'name': 'Sara', 'phone': '0600000002'};
      final model = CashierModel.fromJson(json);
      expect(model.id, 'c2');
    });

    test('fromJson sets station to null when station is absent', () {
      final json = {'_id': 'c3', 'name': 'Ali', 'phone': '0600000003'};
      final model = CashierModel.fromJson(json);
      expect(model.station, isNull);
    });

    test('fromJson sets station to null when station is not a Map', () {
      final json = {
        '_id': 'c4',
        'name': 'Ali',
        'phone': '0600',
        'station': 'invalid'
      };
      final model = CashierModel.fromJson(json);
      expect(model.station, isNull);
    });

    test('toEntity produces DriverEntity', () {
      const model = CashierModel(
        id: 'c1',
        name: 'Ahmed',
        phone: '0600000001',
        station: StationModel(id: 's1', name: 'Gare'),
      );
      final entity = model.toEntity();
      expect(entity, isA<DriverEntity>());
      expect(entity.id, 'c1');
      expect(entity.name, 'Ahmed');
      expect(entity.phone, '0600000001');
      expect(entity.taxiNumber, '');
      expect(entity.plateNumber, '');
      expect(entity.balance, 0.0);
      expect(entity.station, isNotNull);
      expect(entity.station!.id, 's1');
    });

    test('toEntity with no station produces DriverEntity with null station',
        () {
      const model = CashierModel(id: 'c1', name: 'X', phone: '0600');
      final entity = model.toEntity();
      expect(entity.station, isNull);
    });
  });
}
