import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';

abstract class CashoutRepository {
  Future<CashoutsResponseEntity> getCashoutsSummary(
      CashoutSummaryParams params);
}
