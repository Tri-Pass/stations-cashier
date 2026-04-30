import 'package:cashier/features/passengers/data/datasources/passenger_remote_datasource.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final PassengerRemoteDataSource _dataSource;
  PassengerRepositoryImpl(this._dataSource);

  @override
  Future<PassengerEntity> getByNfcTag(String tagId) async {
    final d = await _dataSource.getByNfcTag(tagId);
    final tripsRaw = d['recentTrips'] as List<dynamic>? ?? [];
    return PassengerEntity(
      id: (d['_id'] ?? d['id'] ?? '') as String,
      name: (d['name'] ?? '') as String,
      phone: (d['phone'] ?? '') as String,
      balance: ((d['balance'] ?? 0) as num).toDouble(),
      recentTrips: tripsRaw.map((t) {
        final trip = t as Map<String, dynamic>;
        return PassengerTripEntity(
          from: (trip['from'] ?? '') as String,
          to: (trip['to'] ?? '') as String,
        );
      }).toList(),
    );
  }

  @override
  Future<void> linkNfc(LinkNfcParams params) =>
      _dataSource.linkNfc(params);
}
