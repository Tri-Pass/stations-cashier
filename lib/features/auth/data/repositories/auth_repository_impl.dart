import 'package:cashier/core/storage/local_storage.dart';
import 'package:cashier/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cashier/features/auth/data/models/cashier_model.dart';
import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final LocalStorage _storage;

  AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Future<DriverEntity> login(String phone, String password) async {
    final data = await _dataSource.login(phone, password);
    final token = data['token'] as String;
    await _storage.saveToken(token);
    final model = CashierModel.fromJson(data['cashier'] as Map<String, dynamic>);
    if (model.station != null) {
      await _storage.saveStationId(model.station!.id);
    }
    return model.toEntity();
  }

  @override
  Future<DriverEntity> getProfile() async {
    final data = await _dataSource.getProfile();
    return CashierModel.fromJson(data).toEntity();
  }

  @override
  Future<bool> isAuthenticated() => _storage.hasToken();

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // best-effort — always clear local state
    }
    await _storage.clear();
  }

  @override
  Future<String?> getToken() => _storage.getToken();
}
