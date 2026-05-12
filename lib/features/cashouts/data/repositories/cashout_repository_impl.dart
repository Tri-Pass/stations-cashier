import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/models/cashout_summary_model.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/cashout_repository.dart';

class CashoutRepositoryImpl implements CashoutRepository {
  final CashoutRemoteDataSource _ds;
  CashoutRepositoryImpl(this._ds);

  @override
  Future<CashoutsResponseEntity> getCashoutsSummary(
      CashoutSummaryParams params) async {
    final json = await _ds.getCashoutsSummary(params);
    return CashoutsResponseModel.fromJson(json).toEntity();
  }
}
