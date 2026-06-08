import 'package:cashier/features/lines/data/datasources/lines_remote_datasource.dart';
import 'package:cashier/features/lines/data/repositories/lines_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLinesRemoteDataSource extends Mock implements LinesRemoteDataSource {}

void main() {
  late MockLinesRemoteDataSource dataSource;
  late LinesRepositoryImpl repo;

  setUp(() {
    dataSource = MockLinesRemoteDataSource();
    repo = LinesRepositoryImpl(dataSource);
  });

  group('getLines', () {
    test('maps raw list to StationLineEntity list', () async {
      final raw = [
        {
          '_id': 'l1',
          'origin': 'Rabat',
          'destination': 'Casablanca',
          'price': 50.0,
          'activeTaxiCount': 3,
        }
      ];
      when(() => dataSource.getLines('s1')).thenAnswer((_) async => raw);

      final result = await repo.getLines('s1');

      expect(result.length, 1);
      expect(result.first.id, 'l1');
      expect(result.first.origin, 'Rabat');
      expect(result.first.destination, 'Casablanca');
      expect(result.first.price, 50.0);
      expect(result.first.activeTaxiCount, 3);
    });

    test('returns empty list when datasource returns empty', () async {
      when(() => dataSource.getLines('s1')).thenAnswer((_) async => []);

      final result = await repo.getLines('s1');

      expect(result, isEmpty);
    });
  });

  group('getLineQueue', () {
    test('maps raw list to QueueTaxiEntity list', () async {
      final raw = [
        {
          '_id': 't1',
          'plateNumber': 'ABC-123',
          'totalSeats': 6,
          'occupiedSeats': 2,
          'isFirst': true,
          'driver': {
            'name': 'Ahmed',
            'phone': '0600',
            'licenseNumber': 'L1',
            'balance': 0.0,
          },
        }
      ];
      when(() => dataSource.getLineQueue('s1', 'l1'))
          .thenAnswer((_) async => raw);

      final result = await repo.getLineQueue('s1', 'l1');

      expect(result.length, 1);
      expect(result.first.id, 't1');
      expect(result.first.plateNumber, 'ABC-123');
      expect(result.first.isFirst, isTrue);
      expect(result.first.driver.name, 'Ahmed');
    });

    test('returns empty list when queue is empty', () async {
      when(() => dataSource.getLineQueue('s1', 'l1'))
          .thenAnswer((_) async => []);

      final result = await repo.getLineQueue('s1', 'l1');

      expect(result, isEmpty);
    });
  });
}
