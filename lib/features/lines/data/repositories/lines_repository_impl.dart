import 'package:cashier/features/lines/data/datasources/lines_remote_datasource.dart';
import 'package:cashier/features/lines/domain/entities/station_line_entity.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';

class LinesRepositoryImpl implements LinesRepository {
  final LinesRemoteDataSource _dataSource;
  LinesRepositoryImpl(this._dataSource);

  @override
  Future<List<StationLineEntity>> getLines(String stationId) async {
    final raw = await _dataSource.getLines(stationId);
    return raw.map((e) => _mapLine(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<QueueTaxiEntity>> getLineQueue(
      String stationId, String lineId) async {
    final raw = await _dataSource.getLineQueue(stationId, lineId);
    return raw.map((e) => _mapTaxi(e as Map<String, dynamic>)).toList();
  }

  StationLineEntity _mapLine(Map<String, dynamic> d) {
    return StationLineEntity(
      id: (d['_id'] ?? d['id'] ?? '') as String,
      origin: (d['origin'] ?? '') as String,
      destination: (d['destination'] ?? '') as String,
      price: ((d['price'] ?? 0) as num).toDouble(),
      activeTaxiCount: (d['activeTaxiCount'] ?? 0) as int,
    );
  }

  QueueTaxiEntity _mapTaxi(Map<String, dynamic> d) {
    final driverRaw = d['driver'] as Map<String, dynamic>? ?? {};
    return QueueTaxiEntity(
      id: (d['_id'] ?? d['id'] ?? '') as String,
      plateNumber: (d['plateNumber'] ?? '') as String,
      totalSeats: (d['totalSeats'] ?? 6) as int,
      occupiedSeats: (d['occupiedSeats'] ?? 0) as int,
      isFirst: (d['isFirst'] ?? false) as bool,
      color: d['color'] as String?,
      year: d['year'] as String?,
      driver: QueueDriverEntity(
        name: (driverRaw['name'] ?? '') as String,
        phone: (driverRaw['phone'] ?? '') as String,
        licenseNumber: (driverRaw['licenseNumber'] ?? '') as String,
        permitNumber: driverRaw['permitNumber'] as String?,
        balance: ((driverRaw['balance'] ?? 0) as num).toDouble(),
      ),
    );
  }
}
