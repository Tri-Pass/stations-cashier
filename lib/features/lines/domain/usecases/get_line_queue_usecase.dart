import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';

class GetLineQueueUseCase {
  final LinesRepository _repository;
  GetLineQueueUseCase(this._repository);

  Future<List<QueueTaxiEntity>> call(String stationId, String lineId) =>
      _repository.getLineQueue(stationId, lineId);
}
