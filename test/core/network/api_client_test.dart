import 'dart:convert';

import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

// Builds a MockClient that always returns the given status + body.
MockClient _respond(int status, dynamic body) => MockClient(
      (_) async => http.Response(
        jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      ),
    );

// Builds a MockClient that captures the request for inspection.
MockClient _capture(void Function(http.Request) onRequest,
        [int status = 200, dynamic body = '{}']) =>
    MockClient((req) async {
      onRequest(req);
      return http.Response(jsonEncode(body), status,
          headers: {'content-type': 'application/json'});
    });

void main() {
  late MockLocalStorage storage;
  late ApiClient client;

  setUp(() {
    storage = MockLocalStorage();
    when(() => storage.getToken()).thenAnswer((_) async => null);
  });

  ApiClient make({required MockClient http}) =>
      ApiClient(storage, httpClient: http);

  // ── GET ────────────────────────────────────────────────────────────────────

  group('GET', () {
    test('returns parsed JSON body on 200', () async {
      client = make(http: _respond(200, {'id': '1', 'name': 'test'}));
      final result = await client.get('/some/path');
      expect(result, isA<Map>());
      expect(result['id'], '1');
    });

    test('returns list on 200 with array body', () async {
      client = make(http: _respond(200, [1, 2, 3]));
      final result = await client.get('/list');
      expect(result, [1, 2, 3]);
    });

    test('throws ApiException on 401 using message field', () async {
      client = make(http: _respond(401, {'message': 'Non autorisé'}));
      expect(
        () => client.get('/protected'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Non autorisé')
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('throws ApiException on 404 using error field', () async {
      client = make(http: _respond(404, {'error': 'Ressource introuvable'}));
      expect(
        () => client.get('/missing'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Ressource introuvable')),
      );
    });

    test(
        'throws ApiException with fallback message when body has no message/error',
        () async {
      client = make(http: _respond(500, 'internal error'));
      expect(
        () => client.get('/crash'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Erreur inconnue')
            .having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('includes Authorization header when token is available', () async {
      when(() => storage.getToken()).thenAnswer((_) async => 'my_token');
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.get('/secure');
      expect(captured!.headers['Authorization'], 'Bearer my_token');
    });

    test('does not include Authorization header when no token', () async {
      when(() => storage.getToken()).thenAnswer((_) async => null);
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.get('/public');
      expect(captured!.headers.containsKey('Authorization'), isFalse);
    });

    test('always includes Content-Type: application/json', () async {
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.get('/any');
      expect(captured!.headers['Content-Type'], 'application/json');
    });
  });

  // ── POST ───────────────────────────────────────────────────────────────────

  group('POST', () {
    test('sends JSON-encoded body', () async {
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.post('/create', {'key': 'value'});
      final decoded = jsonDecode(captured!.body) as Map;
      expect(decoded['key'], 'value');
    });

    test('returns parsed JSON body on 201', () async {
      client = make(http: _respond(201, {'bookingId': 'b1'}));
      final result = await client.post('/bookings', {});
      expect(result['bookingId'], 'b1');
    });

    test('throws ApiException on 400 with message', () async {
      client = make(http: _respond(400, {'message': 'Données invalides'}));
      expect(
        () => client.post('/bad', {}),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Données invalides')
            .having((e) => e.statusCode, 'statusCode', 400)),
      );
    });

    test('omits Authorization when auth: false', () async {
      when(() => storage.getToken()).thenAnswer((_) async => 'tok');
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.post('/login', {}, auth: false);
      expect(captured!.headers.containsKey('Authorization'), isFalse);
    });

    test('includes Authorization when auth: true (default)', () async {
      when(() => storage.getToken()).thenAnswer((_) async => 'tok');
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.post('/create', {});
      expect(captured!.headers['Authorization'], 'Bearer tok');
    });
  });

  // ── PUT ────────────────────────────────────────────────────────────────────

  group('PUT', () {
    test('sends JSON-encoded body', () async {
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.put('/update', {'field': 'updated'});
      final decoded = jsonDecode(captured!.body) as Map;
      expect(decoded['field'], 'updated');
    });

    test('returns parsed body on 200', () async {
      client = make(http: _respond(200, {'ok': true}));
      final result = await client.put('/update', {});
      expect(result['ok'], isTrue);
    });

    test('throws ApiException on 422', () async {
      client = make(http: _respond(422, {'message': 'Non traitable'}));
      expect(
        () => client.put('/bad', {}),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });

    test('includes Authorization header', () async {
      when(() => storage.getToken()).thenAnswer((_) async => 'tok');
      http.Request? captured;
      client = make(http: _capture((r) => captured = r));
      await client.put('/update', {});
      expect(captured!.headers['Authorization'], 'Bearer tok');
    });
  });

  // ── ApiException ──────────────────────────────────────────────────────────

  group('ApiException', () {
    test('toString returns the message', () {
      final e = ApiException('Erreur de test', 500);
      expect(e.toString(), 'Erreur de test');
    });
  });
}
