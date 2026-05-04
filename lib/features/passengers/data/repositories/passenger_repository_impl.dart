import 'package:cashier/features/passengers/data/datasources/passenger_remote_datasource.dart';
import 'package:cashier/features/passengers/data/models/passenger_model.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final PassengerRemoteDataSource _dataSource;
  PassengerRepositoryImpl(this._dataSource);

  @override
  Future<PassengerEntity> getByNfcTag(String tagId) async {
    final data = await _dataSource.getByNfcTag(tagId);
    return PassengerModel.fromJson(data).toEntity();
  }

  @override
  Future<void> linkNfc(LinkNfcParams params) => _dataSource.linkNfc(params);

  @override
  Future<void> recharge(RechargeParams params) => _dataSource.recharge(params);

  @override
  Future<NfcTopupResult> nfcTopup(NfcTopupParams params) =>
      _dataSource.nfcTopup(params);

  @override
  Future<NfcTopupResult> phoneTopup(PhoneTopupParams params) =>
      _dataSource.phoneTopup(params);
}
