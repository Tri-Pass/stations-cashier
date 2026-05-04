import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class NfcTopupUseCase {
  final PassengerRepository _repository;
  NfcTopupUseCase(this._repository);

  Future<NfcTopupResult> call(NfcTopupParams params) =>
      _repository.nfcTopup(params);
}
