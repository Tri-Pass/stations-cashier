import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';

abstract class LinesRepository {
  Future<List<StationLineEntity>> getLines(String stationId);
  Future<List<QueueTaxiEntity>> getLineQueue(String stationId, String lineId);
}
