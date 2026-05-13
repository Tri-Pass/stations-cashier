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
  static const String tickets         = '/api/cashier/ticket';

  // ── Socket channels ───────────────────────────────────────────────────────
  static String stationChannel(String stationId) => 'station/$stationId';
}
