import 'package:cashier/features/cashouts/data/models/cashout_summary_model.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CashoutDriverModel', () {
    test('fromJson maps _id', () {
      final m = CashoutDriverModel.fromJson(
          {'_id': 'd1', 'name': 'Ahmed', 'phone': '0600'});
      expect(m.id, 'd1');
      expect(m.name, 'Ahmed');
      expect(m.phone, '0600');
    });

    test('fromJson maps id fallback', () {
      final m = CashoutDriverModel.fromJson(
          {'id': 'd2', 'name': 'Sara', 'phone': '0611'});
      expect(m.id, 'd2');
    });

    test('toEntity maps correctly', () {
      final entity =
          const CashoutDriverModel(id: 'd1', name: 'Ahmed', phone: '0600')
              .toEntity();
      expect(entity, isA<CashoutDriverEntity>());
      expect(entity.id, 'd1');
    });
  });

  group('CashoutTaxiModel', () {
    test('fromJson maps plate_number key', () {
      final m =
          CashoutTaxiModel.fromJson({'_id': 't1', 'plate_number': 'ABC-123'});
      expect(m.plateNumber, 'ABC-123');
    });

    test('fromJson maps plateNumber camelCase key', () {
      final m =
          CashoutTaxiModel.fromJson({'id': 't2', 'plateNumber': 'XYZ-999'});
      expect(m.plateNumber, 'XYZ-999');
    });
  });

  group('CashoutLineModel', () {
    test('fromJson maps standard fields', () {
      final m = CashoutLineModel.fromJson(
          {'id': 'l1', 'origin': 'Fes', 'destination': 'Rabat', 'price': 40.0});
      expect(m.origin, 'Fes');
      expect(m.destination, 'Rabat');
      expect(m.price, 40.0);
    });

    test('fromLineString with → separator', () {
      final m = CashoutLineModel.fromLineString('Casablanca → Marrakech');
      expect(m.origin, 'Casablanca');
      expect(m.destination, 'Marrakech');
    });

    test('fromLineString without separator uses whole string as origin', () {
      final m = CashoutLineModel.fromLineString('Agadir');
      expect(m.origin, 'Agadir');
      expect(m.destination, '');
    });
  });

  group('CashoutSummaryModel', () {
    final json = {
      '_id': 's1',
      'driver': {'id': 'd1', 'name': 'Ahmed', 'phone': '0600'},
      'taxi': {'id': 't1', 'plateNumber': 'ABC-123'},
      'line': {
        'id': 'l1',
        'origin': 'Fes',
        'destination': 'Rabat',
        'price': 40.0
      },
      'ticketsCount': 5,
      'totalCollected': 200.0,
      'totalCash': 120.0,
      'totalNfc': 80.0,
      'departedAt': '2024-06-01T09:00:00Z',
    };

    test('fromJson maps all fields using API key names', () {
      final model = CashoutSummaryModel.fromJson(json);
      expect(model.id, 's1');
      expect(model.totalSeats, 5);
      expect(model.totalAmount, 200.0);
      expect(model.cashAmount, 120.0);
      expect(model.nfcAmount, 80.0);
      expect(model.departedAt, isNotNull);
    });

    test('fromJson falls back to totalAmount/cashAmount camelCase', () {
      final j = {
        '_id': 's2',
        'driver': <String, dynamic>{},
        'taxi': <String, dynamic>{},
        'totalSeats': 3,
        'totalAmount': 150.0,
        'cashAmount': 90.0,
        'nfcAmount': 60.0,
      };
      final model = CashoutSummaryModel.fromJson(j);
      expect(model.totalSeats, 3);
      expect(model.totalAmount, 150.0);
    });

    test('fromJson parses line from taxi.line string', () {
      final j = {
        '_id': 's3',
        'driver': <String, dynamic>{},
        'taxi': <String, dynamic>{
          'id': 't1',
          'plateNumber': 'P1',
          'line': 'Oujda → Nador'
        },
      };
      final model = CashoutSummaryModel.fromJson(j);
      expect(model.line.origin, 'Oujda');
      expect(model.line.destination, 'Nador');
    });

    test('toEntity maps to CashoutSummaryEntity', () {
      final entity = CashoutSummaryModel.fromJson(json).toEntity();
      expect(entity, isA<CashoutSummaryEntity>());
      expect(entity.totalAmount, 200.0);
      expect(entity.driver.name, 'Ahmed');
    });
  });

  group('CashoutsResponseModel', () {
    test('fromJson with plain list computes totalAmount', () {
      final list = [
        <String, dynamic>{
          '_id': 's1',
          'driver': <String, dynamic>{},
          'taxi': <String, dynamic>{},
          'totalCollected': 100.0,
        },
        <String, dynamic>{
          '_id': 's2',
          'driver': <String, dynamic>{},
          'taxi': <String, dynamic>{},
          'totalCollected': 50.0,
        },
      ];
      final model = CashoutsResponseModel.fromJson(list);
      expect(model.cashouts.length, 2);
      expect(model.totalAmount, 150.0);
    });

    test('fromJson with data envelope uses statsMap totalCollected', () {
      final json = <String, dynamic>{
        'status': 'ok',
        'data': <String, dynamic>{
          'stats': <String, dynamic>{'totalCollected': 300.0},
          'driverRows': [
            <String, dynamic>{
              '_id': 's1',
              'driver': <String, dynamic>{},
              'taxi': <String, dynamic>{},
              'totalCollected': 300.0
            },
          ],
        },
      };
      final model = CashoutsResponseModel.fromJson(json);
      expect(model.cashouts.length, 1);
      expect(model.totalAmount, 300.0);
    });

    test('fromJson with envelope falls back to summing items when no apiTotal',
        () {
      final json = <String, dynamic>{
        'data': <String, dynamic>{
          'driverRows': [
            <String, dynamic>{
              '_id': 's1',
              'driver': <String, dynamic>{},
              'taxi': <String, dynamic>{},
              'totalCollected': 75.0
            },
            <String, dynamic>{
              '_id': 's2',
              'driver': <String, dynamic>{},
              'taxi': <String, dynamic>{},
              'totalCollected': 25.0
            },
          ],
        },
      };
      final model = CashoutsResponseModel.fromJson(json);
      expect(model.totalAmount, 100.0);
    });

    test('toEntity maps to CashoutsResponseEntity', () {
      final entity = CashoutsResponseModel.fromJson([]).toEntity();
      expect(entity, isA<CashoutsResponseEntity>());
      expect(entity.cashouts, isEmpty);
      expect(entity.totalAmount, 0.0);
    });
  });
}
