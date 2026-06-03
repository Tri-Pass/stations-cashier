import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';

class LinkNfcUseCase {
  final PassengerRepository _repository;
  LinkNfcUseCase(this._repository);

  Future<void> call(LinkNfcParams params) => _repository.linkNfc(params);
}
