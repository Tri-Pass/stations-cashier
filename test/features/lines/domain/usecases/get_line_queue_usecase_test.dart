import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';
import 'package:cashier/features/lines/domain/usecases/get_line_queue_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLinesRepository extends Mock implements LinesRepository {}

void main() {
  late MockLinesRepository repo;

  setUp(() {
    repo = MockLinesRepository();
  });

  test('delegates to repository.getLineQueue and returns results', () async {
    when(() => repo.getLineQueue('s1', 'l1')).thenAnswer((_) async => []);

    final result = await GetLineQueueUseCase(repo).call('s1', 'l1');

    expect(result, isEmpty);
    verify(() => repo.getLineQueue('s1', 'l1')).called(1);
  });

  test('returns taxi list from repository', () async {
    final taxis = [
      const QueueTaxiEntity(
        id: 't1',
        plateNumber: 'ABC-123',
        totalSeats: 6,
        occupiedSeats: 2,
        isFirst: true,
        driver: QueueDriverEntity(
          name: 'Ahmed',
          phone: '0600',
          licenseNumber: 'L1',
          balance: 0,
        ),
      ),
    ];
    when(() => repo.getLineQueue(any(), any())).thenAnswer((_) async => taxis);

    final result = await GetLineQueueUseCase(repo).call('s1', 'l1');

    expect(result, taxis);
  });
}
