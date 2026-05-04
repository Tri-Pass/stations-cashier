import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class RechargeUseCase {
  final PassengerRepository _repository;
  RechargeUseCase(this._repository);

  Future<void> call(RechargeParams params) => _repository.recharge(params);
}
