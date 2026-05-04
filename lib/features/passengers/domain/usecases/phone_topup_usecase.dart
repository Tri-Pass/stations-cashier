import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class PhoneTopupUseCase {
  final PassengerRepository _repository;
  PhoneTopupUseCase(this._repository);

  Future<NfcTopupResult> call(PhoneTopupParams params) =>
      _repository.phoneTopup(params);
}
