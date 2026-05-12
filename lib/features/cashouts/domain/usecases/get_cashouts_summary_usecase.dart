import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/cashout_repository.dart';

class GetCashoutsSummaryUseCase {
  final CashoutRepository _repo;
  GetCashoutsSummaryUseCase(this._repo);

  Future<CashoutsResponseEntity> call(CashoutSummaryParams params) =>
      _repo.getCashoutsSummary(params);
}
