import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class GetPassengerByNfcUseCase {
  final PassengerRepository _repository;
  GetPassengerByNfcUseCase(this._repository);

  Future<PassengerEntity> call(String tagId) =>
      _repository.getByNfcTag(tagId);
}
