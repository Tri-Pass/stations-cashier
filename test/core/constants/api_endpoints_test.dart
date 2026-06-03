import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEndpoints — dynamic path builders', () {
    test('lines builds path with stationId', () {
      expect(ApiEndpoints.lines('s1'), '/api/cashier/stations/s1/lines');
    });

    test('lineQueue builds path with stationId and lineId', () {
      expect(
        ApiEndpoints.lineQueue('s1', 'l2'),
        '/api/cashier/stations/s1/lines/l2/queue',
      );
    });

    test('driverByNfc includes tagId as query param', () {
      expect(ApiEndpoints.driverByNfc('TAG123'),
          '/api/courtier/drivers/nfc?tagId=TAG123');
    });

    test('passengerByNfc includes tagId as path segment', () {
      expect(ApiEndpoints.passengerByNfc('NFC1'),
          '/api/cashier/passengers/nfc/NFC1');
    });

    test('nfcTopup builds path with tagId', () {
      expect(ApiEndpoints.nfcTopup('TAG1'),
          '/api/cashier/passengers/nfc/TAG1/topup');
    });

    test('phoneTopup builds path with phone', () {
      expect(ApiEndpoints.phoneTopup('0600000001'),
          '/api/cashier/passengers/phone/0600000001/topup');
    });

    test('walletOptions includes type param', () {
      expect(ApiEndpoints.walletOptions('withdraw'),
          '/api/cashier/wallet/options?type=withdraw');
      expect(ApiEndpoints.walletOptions('topup'),
          '/api/cashier/wallet/options?type=topup');
    });

    test('walletCandidates includes page=1 and search param', () {
      final url = ApiEndpoints.walletCandidates('ali');
      expect(url, contains('page=1'));
      expect(url, contains('search=ali'));
    });

    test('cashierWalletChannel returns cashier-wallet-{id}', () {
      expect(ApiEndpoints.cashierWalletChannel('c1'), 'cashier-wallet-c1');
    });

    test('stationChannel returns station/{id}', () {
      expect(ApiEndpoints.stationChannel('s5'), 'station/s5');
    });
  });

  group('ApiEndpoints — constant values', () {
    test('login endpoint is correct', () {
      expect(ApiEndpoints.login, '/api/cashier/auth/login');
    });

    test('me endpoint is correct', () {
      expect(ApiEndpoints.me, '/api/cashier/auth/me');
    });

    test('logout endpoint is correct', () {
      expect(ApiEndpoints.logout, '/api/cashier/auth/cashier/logout');
    });

    test('bookings endpoint is correct', () {
      expect(ApiEndpoints.bookings, '/api/cashier/bookings');
    });

    test('cashoutsSummary endpoint is correct', () {
      expect(ApiEndpoints.cashoutsSummary, '/api/cashier/cashouts/summary');
    });

    test('ticketsList endpoint is correct', () {
      expect(ApiEndpoints.ticketsList, '/api/cashier/ticket');
    });

    test('cashout endpoint is correct', () {
      expect(ApiEndpoints.cashout, '/api/cashier/cashout');
    });

    test('walletData endpoint is correct', () {
      expect(ApiEndpoints.walletData, '/api/cashier/wallet/data');
    });
  });
}
