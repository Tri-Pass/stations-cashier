import 'package:cashier/core/config/env.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => Env.baseApiUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login  = '/auth/login';
  static const String me     = '/auth/me';
  static const String logout = '/auth/cashier/logout';

  // ── Lines & queue ─────────────────────────────────────────────────────────
  static String lines(String stationId) =>
      '/stations/$stationId/lines';

  static String lineQueue(String stationId, String lineId) =>
      '/stations/$stationId/lines/$lineId/queue';

  // ── Bookings ──────────────────────────────────────────────────────────────
  static const String bookings = '/bookings';

  // ── Passengers / NFC ──────────────────────────────────────────────────────
  static String passengerByNfc(String tagId) =>
      '/passengers/nfc/$tagId';

  static const String linkNfc = '/passengers/nfc/link';

  // ── Socket channels ───────────────────────────────────────────────────────
  static String stationChannel(String stationId) => 'station/$stationId';
}
