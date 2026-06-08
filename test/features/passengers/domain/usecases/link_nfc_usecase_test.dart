import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/link_nfc_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRepository extends Mock implements PassengerRepository {}

void main() {
  late MockPassengerRepository repo;

  setUp(() {
    repo = MockPassengerRepository();
    registerFallbackValue(
        const LinkNfcParams(phone: '0600', nfcTagId: 'tag-1'));
  });

  test('delegates to repository.linkNfc', () async {
    const params = LinkNfcParams(phone: '0600', nfcTagId: 'tag-1', name: 'Ali');
    when(() => repo.linkNfc(any())).thenAnswer((_) async {});

    await LinkNfcUseCase(repo).call(params);

    verify(() => repo.linkNfc(params)).called(1);
  });
}
