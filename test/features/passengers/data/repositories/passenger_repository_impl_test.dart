import 'package:cashier/features/passengers/data/datasources/passenger_remote_datasource.dart';
import 'package:cashier/features/passengers/data/repositories/passenger_repository_impl.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRemoteDataSource extends Mock
    implements PassengerRemoteDataSource {}

const _topupResult = NfcTopupResult(
  id: 'p1',
  name: 'Ali',
  phone: '0600',
  nfcTagId: 'tag-1',
  balanceBefore: 100,
  balanceAfter: 150,
  amount: 50,
);

void main() {
  late MockPassengerRemoteDataSource dataSource;
  late PassengerRepositoryImpl repo;

  setUp(() {
    dataSource = MockPassengerRemoteDataSource();
    repo = PassengerRepositoryImpl(dataSource);
    registerFallbackValue(
        const LinkNfcParams(phone: '0600', nfcTagId: 'tag-1'));
    registerFallbackValue(const RechargeParams(nfcTagId: 'tag-1', amount: 50));
    registerFallbackValue(const NfcTopupParams(nfcTagId: 'tag-1', amount: 50));
    registerFallbackValue(const PhoneTopupParams(phone: '0600', amount: 50));
  });

  group('getByNfcTag', () {
    test('returns PassengerEntity parsed from datasource', () async {
      when(() => dataSource.getByNfcTag('tag-001')).thenAnswer((_) async => {
            '_id': 'p1',
            'name': 'Ali',
            'phone': '0600',
            'balance': 100.0,
            'recentTrips': <dynamic>[],
          });

      final result = await repo.getByNfcTag('tag-001');

      expect(result.id, 'p1');
      expect(result.name, 'Ali');
      expect(result.balance, 100.0);
    });
  });

  group('linkNfc', () {
    test('delegates to datasource.linkNfc', () async {
      when(() => dataSource.linkNfc(any())).thenAnswer((_) async {});
      const params = LinkNfcParams(phone: '0600', nfcTagId: 'tag-1');

      await repo.linkNfc(params);

      verify(() => dataSource.linkNfc(params)).called(1);
    });
  });

  group('recharge', () {
    test('delegates to datasource.recharge', () async {
      when(() => dataSource.recharge(any())).thenAnswer((_) async {});
      const params = RechargeParams(nfcTagId: 'tag-1', amount: 50);

      await repo.recharge(params);

      verify(() => dataSource.recharge(params)).called(1);
    });
  });

  group('nfcTopup', () {
    test('delegates to datasource.nfcTopup and returns result', () async {
      when(() => dataSource.nfcTopup(any()))
          .thenAnswer((_) async => _topupResult);
      const params = NfcTopupParams(nfcTagId: 'tag-1', amount: 50);

      final result = await repo.nfcTopup(params);

      expect(result, _topupResult);
      verify(() => dataSource.nfcTopup(params)).called(1);
    });
  });

  group('phoneTopup', () {
    test('delegates to datasource.phoneTopup and returns result', () async {
      when(() => dataSource.phoneTopup(any()))
          .thenAnswer((_) async => _topupResult);
      const params = PhoneTopupParams(phone: '0600', amount: 50);

      final result = await repo.phoneTopup(params);

      expect(result, _topupResult);
      verify(() => dataSource.phoneTopup(params)).called(1);
    });
  });
}
