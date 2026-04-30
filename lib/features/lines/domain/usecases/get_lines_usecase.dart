import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';

class GetLinesUseCase {
  final LinesRepository _repository;
  GetLinesUseCase(this._repository);

  Future<List<StationLineEntity>> call(String stationId) =>
      _repository.getLines(stationId);
}
