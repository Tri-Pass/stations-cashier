import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';
import 'package:cashier/features/lines/domain/usecases/get_lines_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLinesRepository extends Mock implements LinesRepository {}

void main() {
  late MockLinesRepository repository;
  late GetLinesUseCase useCase;

  const line = StationLineEntity(
    id: 'l1',
    origin: 'Casablanca',
    destination: 'Marrakech',
    price: 55.0,
    activeTaxiCount: 3,
  );

  setUp(() {
    repository = MockLinesRepository();
    useCase = GetLinesUseCase(repository);
  });

  test('delegates to repository.getLines with stationId', () async {
    when(() => repository.getLines('s1')).thenAnswer((_) async => [line]);

    final result = await useCase('s1');

    expect(result, [line]);
    verify(() => repository.getLines('s1')).called(1);
  });

  test('returns empty list when no lines exist', () async {
    when(() => repository.getLines(any())).thenAnswer((_) async => []);

    final result = await useCase('s2');

    expect(result, isEmpty);
  });

  test('propagates repository exception', () async {
    when(() => repository.getLines(any())).thenThrow(Exception('network error'));
    expect(() => useCase('s1'), throwsA(isA<Exception>()));
  });
}
