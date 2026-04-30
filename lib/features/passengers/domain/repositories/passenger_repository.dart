import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';

abstract class PassengerRepository {
  Future<PassengerEntity> getByNfcTag(String tagId);
  Future<void> linkNfc(LinkNfcParams params);
}
