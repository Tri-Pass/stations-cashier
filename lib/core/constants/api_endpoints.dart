import 'package:cashier/core/config/env.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => Env.baseApiUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login  = '/api/cashier/auth/login';
  static const String me     = '/api/cashier/auth/me';
  static const String logout = '/api/cashier/auth/cashier/logout';

  // ── Lines & queue ─────────────────────────────────────────────────────────
  static String lines(String stationId) =>
      '/api/cashier/stations/$stationId/lines';

  static String lineQueue(String stationId, String lineId) =>
      '/api/cashier/stations/$stationId/lines/$lineId/queue';

  // ── Bookings ──────────────────────────────────────────────────────────────
  static const String bookings = '/api/cashier/bookings';

  // ── Drivers / NFC ─────────────────────────────────────────────────────────
  static String driverByNfc(String tagId) => '/api/courtier/drivers/nfc?tagId=$tagId';

  // ── Queue ──────────────────────────────────────────────────────────────────
  static const String queue = '/api/courtier/queue';

  // ── Passengers / NFC ──────────────────────────────────────────────────────
  static String passengerByNfc(String tagId) =>
      '/api/cashier/passengers/nfc/$tagId';

  static const String linkNfc           = '/api/cashier/passengers/nfc/link';
  static const String rechargePassenger = '/api/cashier/passengers/recharge';

  static String nfcTopup(String tagId)     => '/api/cashier/passengers/nfc/$tagId/topup';
  static String phoneTopup(String phone)   => '/api/cashier/passengers/phone/$phone/topup';

  // ── Cashouts ──────────────────────────────────────────────────────────────
  static const String cashoutsSummary = '/api/cashier/cashouts/summary';
  static const String ticketsList     = '/api/cashier/ticket';
  static const String cashout         = '/api/cashier/cashout';

  // ── Wallet (cashier's own wallet) ─────────────────────────────────────────
  static const String walletData     = '/api/cashier/wallet/data';
  static const String walletIncrease = '/api/cashier/wallet/increase';
  static const String walletWithdraw = '/api/cashier/wallet/withdraw';
  static const String walletTransfer = '/api/cashier/wallet/transfer';
  static const String walletCheckPin = '/api/cashier/wallet/check/codePin';
  static const String ribTransferRequest = '/api/cashier/rib-transfer/request';
  static const String cashplusCredit = '/api/cashier/cashplus/transactions/creditwallet';

  static String walletOptions(String type) =>
      '/api/cashier/wallet/options?type=$type';

  static String walletCandidates(String search) =>
      '/api/cashier/wallet/candidates?page=1&search=${Uri.encodeComponent(search)}';

  static String cashierWalletChannel(String cashierId) =>
      'cashier-wallet-$cashierId';

  // ── Socket channels ───────────────────────────────────────────────────────
  static String stationChannel(String stationId) => 'station/$stationId';
}
