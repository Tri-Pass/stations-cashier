import 'package:cashier/features/lines/data/datasources/lines_remote_datasource.dart';
import 'package:cashier/features/lines/data/models/station_line_model.dart';
import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';

class LinesRepositoryImpl implements LinesRepository {
  final LinesRemoteDataSource _dataSource;
  LinesRepositoryImpl(this._dataSource);

  @override
  Future<List<StationLineEntity>> getLines(String stationId) async {
    final raw = await _dataSource.getLines(stationId);
    return raw
        .map((e) => StationLineModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<QueueTaxiEntity>> getLineQueue(String stationId, String lineId) async {
    final raw = await _dataSource.getLineQueue(stationId, lineId);
    return raw
        .map((e) => QueueTaxiModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
