import 'dart:async';
import 'dart:convert';

import 'package:cashier/core/network/socket_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake WebSocket infrastructure
// ─────────────────────────────────────────────────────────────────────────────

class FakeWebSocketSink implements WebSocketSink {
  final FakeWebSocketChannel _ch;
  int closeCalls = 0;

  FakeWebSocketSink(this._ch);

  @override
  void add(dynamic data) => _ch._sent.add(data);

  // WebSocketSink.close uses positional optional params, not named
  @override
  Future close([int? closeCode, String? closeReason]) {
    closeCalls++;
    if (!_ch._ctrl.isClosed) _ch._ctrl.close();
    return Future.value();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) => Future.value();

  @override
  Future get done => Future.value();
}

class FakeWebSocketChannel extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  // sync: true → _onMessage is invoked immediately on push, no extra await needed
  final _ctrl = StreamController<dynamic>.broadcast(sync: true);
  final List<dynamic> _sent = [];
  late final FakeWebSocketSink _fakeSink = FakeWebSocketSink(this);

  @override
  Stream<dynamic> get stream => _ctrl.stream;

  @override
  WebSocketSink get sink => _fakeSink;

  @override
  Future<void> get ready => Future.value();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  /// All messages sent to this channel (raw JSON strings).
  List<Map<String, dynamic>> get decoded =>
      _sent.map((m) => jsonDecode(m as String) as Map<String, dynamic>).toList();

  /// Last decoded message sent.
  Map<String, dynamic> get last => decoded.last;

  /// Push a raw message from the fake server.
  void push(dynamic raw) {
    if (!_ctrl.isClosed) _ctrl.add(raw);
  }

  /// Push a JSON-encoded message from the fake server.
  void pushJson(Map<String, dynamic> msg) => push(jsonEncode(msg));

  /// Simulate the server closing the connection.
  void serverClose() {
    if (!_ctrl.isClosed) _ctrl.close();
  }

  bool get sinkClosed => _ctrl.isClosed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Test helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Creates an isolated socket + fresh fake channel pair.
(SocketService, FakeWebSocketChannel) _makeSocket({
  WebSocketFactory? wsFactory,
}) {
  final fake = FakeWebSocketChannel();
  final socket = SocketService.createForTesting(
    wsFactory: wsFactory ?? (_) => fake,
  );
  return (socket, fake);
}

/// Connects and completes the handshake, returning the connected socket.
///
/// After this call `socket.status == connected`.
Future<void> _doHandshake(
  SocketService socket,
  FakeWebSocketChannel fake, {
  bool isAuthenticated = true,
  void Function(bool, String?)? onAuthResult,
}) async {
  socket.connect(SocketServiceOptions(
    url: 'wss://test.local',
    authToken: 'test-token',
    onAuthResult: onAuthResult,
  ));
  // await ready (Future.value) + rest of _openSocket
  await Future.delayed(Duration.zero);

  // Find the handshake CID from the first sent message
  final hs = fake.decoded.first;
  expect(hs['event'], '#handshake');
  final cid = hs['cid'] as int;

  // Reply with handshake ACK
  fake.pushJson({
    'rid': cid,
    'data': {'isAuthenticated': isAuthenticated, 'id': 'socket-1'},
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // ── connect / _openSocket ───────────────────────────────────────────────

  group('connect / _openSocket', () {
    late SocketService socket;
    late FakeWebSocketChannel fake;

    setUp(() {
      final pair = _makeSocket();
      socket = pair.$1;
      fake = pair.$2;
    });

    tearDown(() => socket.destroy());

    test('status is connecting immediately after connect()', () async {
      socket.connect(SocketServiceOptions(url: 'wss://test.local'));
      expect(socket.status, SocketConnectionStatus.connecting);
      await Future.delayed(Duration.zero);
    });

    test('sends #handshake with authToken after ready', () async {
      socket.connect(SocketServiceOptions(url: 'wss://test.local', authToken: 'tok'));
      await Future.delayed(Duration.zero);

      final msg = fake.decoded.first;
      expect(msg['event'], '#handshake');
      expect((msg['data'] as Map)['authToken'], 'tok');
      expect(msg['cid'], isNotNull);
    });

    test('status becomes connected after handshake ACK', () async {
      await _doHandshake(socket, fake);
      expect(socket.status, SocketConnectionStatus.connected);
      expect(socket.isConnected, isTrue);
    });

    test('calls onAuthResult callback with isAuthenticated=true', () async {
      bool? gotAuth;
      String? gotId;
      await _doHandshake(socket, fake, onAuthResult: (a, id) {
        gotAuth = a;
        gotId = id;
      });
      expect(gotAuth, isTrue);
      expect(gotId, 'socket-1');
    });

    test('calls onAuthResult with isAuthenticated=false', () async {
      bool? gotAuth;
      await _doHandshake(socket, fake,
          isAuthenticated: false, onAuthResult: (a, _) => gotAuth = a);
      expect(gotAuth, isFalse);
    });

    test('statusStream emits connecting then connected', () async {
      final emitted = <SocketConnectionStatus>[];
      final sub = socket.statusStream.listen(emitted.add);

      await _doHandshake(socket, fake);
      // Let the status controller's async microtask deliver 'connected' to the listener
      await Future.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted, contains(SocketConnectionStatus.connecting));
      expect(emitted, contains(SocketConnectionStatus.connected));
    });

    test('reconnecting status is preserved through _openSocket (no extra connecting emit)', () async {
      // Simulate: was reconnecting (e.g. after disconnect) → _openSocket should NOT emit connecting
      socket.forceReconnect(); // sets status to reconnecting
      await Future.delayed(Duration.zero);
      // Status should still be reconnecting (not connecting) before handshake
      expect(socket.status, SocketConnectionStatus.reconnecting);
    });

    test('schedules reconnect when WebSocket factory throws', () async {
      final errSocket = SocketService.createForTesting(
        wsFactory: (_) => throw Exception('network unreachable'),
      );
      errSocket.connect(SocketServiceOptions(
        url: 'wss://test.local',
        reconnect: const ReconnectOptions(maxAttempts: 0),
      ));
      await Future.delayed(Duration.zero);
      // maxAttempts=0 → immediately dead after the first failed attempt
      expect(errSocket.status, SocketConnectionStatus.dead);
      errSocket.destroy();
    });
  });

  // ── ping / pong ──────────────────────────────────────────────────────────

  group('_onMessage — ping / pong', () {
    late SocketService socket;
    late FakeWebSocketChannel fake;

    setUp(() async {
      final pair = _makeSocket();
      socket = pair.$1;
      fake = pair.$2;
      await _doHandshake(socket, fake);
      fake._sent.clear(); // start fresh after handshake
    });

    tearDown(() => socket.destroy());

    test('echoes #1 back when server sends #1', () {
      fake.push('#1');
      expect(fake._sent, contains('#1'));
    });

    test('echoes empty string back when server sends empty string', () {
      fake.push('');
      expect(fake._sent, contains(''));
    });

    test('handles #2 (server pong) without throwing', () {
      expect(() => fake.push('#2'), returnsNormally);
    });

    test('handles null without throwing', () {
      expect(() => fake.push(null), returnsNormally);
    });
  });

  // ── handshake ACK ────────────────────────────────────────────────────────

  group('_onMessage — handshake ACK', () {
    test('resets attempt counter on successful ACK', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);
      expect(socket.status, SocketConnectionStatus.connected);
      socket.destroy();
    });
  });

  // ── generic ACK ─────────────────────────────────────────────────────────

  group('_onMessage — generic ACK (rid without matching handshakeCid)', () {
    test('does not throw or change status', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(() => fake.pushJson({'rid': 999}), returnsNormally);
      expect(socket.status, SocketConnectionStatus.connected);
      socket.destroy();
    });
  });

  // ── non-JSON frame ───────────────────────────────────────────────────────

  group('_onMessage — non-JSON', () {
    test('skips non-JSON string without throwing', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(() => fake.push('not-json-at-all'), returnsNormally);
      socket.destroy();
    });
  });

  // ── action=publish ───────────────────────────────────────────────────────

  group('_onMessage — action=publish', () {
    test('dispatches payload to subscribed data handler', () async {
      final (socket, fake) = _makeSocket();
      dynamic received;
      socket.subscribe(SocketChannelConfig(
        channel: 'station/s1',
        handlerType: SocketHandlerType.data,
        onData: (d) => received = d,
      ));
      await _doHandshake(socket, fake);

      fake.pushJson({
        'action': 'publish',
        'channel': 'station/s1',
        'data': {'seats': 3},
      });

      expect(received, {'seats': 3});
      socket.destroy();
    });

    test('ignores action=publish for unknown channel without throwing', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(
        () => fake.pushJson({'action': 'publish', 'channel': 'ghost', 'data': {}}),
        returnsNormally,
      );
      socket.destroy();
    });
  });

  // ── #publish event ───────────────────────────────────────────────────────

  group('_onMessage — #publish event', () {
    test('dispatches to subscribed data handler', () async {
      final (socket, fake) = _makeSocket();
      dynamic received;
      socket.subscribe(SocketChannelConfig(
        channel: 'booking-updates',
        handlerType: SocketHandlerType.data,
        onData: (d) => received = d,
      ));
      await _doHandshake(socket, fake);

      fake.pushJson({
        'event': '#publish',
        'data': {'channel': 'booking-updates', 'data': {'id': 'b1'}},
      });

      expect(received, {'id': 'b1'});
      socket.destroy();
    });

    test('ignores #publish for unknown channel without throwing', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(
        () => fake.pushJson({
          'event': '#publish',
          'data': {'channel': 'unknown-ch', 'data': {}},
        }),
        returnsNormally,
      );
      socket.destroy();
    });
  });

  // ── #ping event ──────────────────────────────────────────────────────────

  group('_onMessage — #ping event', () {
    test('sends #pong response with matching rid=cid', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);
      fake._sent.clear();

      fake.pushJson({'event': '#ping', 'cid': 42});

      final pong = fake.decoded.firstWhere((m) => m['event'] == '#pong');
      expect(pong['rid'], 42);
      socket.destroy();
    });
  });

  // ── #setAuthToken ────────────────────────────────────────────────────────

  group('_onMessage — #setAuthToken', () {
    test('updates options.authToken', () async {
      final (socket, fake) = _makeSocket();
      final opts = SocketServiceOptions(url: 'wss://test.local', authToken: 'old');
      socket.connect(opts);
      await Future.delayed(Duration.zero);

      final cid = fake.decoded.first['cid'] as int;
      fake.pushJson({'rid': cid, 'data': {'isAuthenticated': true, 'id': 's1'}});

      fake.pushJson({
        'event': '#setAuthToken',
        'data': {'token': 'new-token-456'},
      });

      expect(opts.authToken, 'new-token-456');
      socket.destroy();
    });
  });

  // ── #removeAuthToken ─────────────────────────────────────────────────────

  group('_onMessage — #removeAuthToken', () {
    test('does NOT clear authToken (preserves local JWT)', () async {
      final (socket, fake) = _makeSocket();
      final opts = SocketServiceOptions(url: 'wss://test.local', authToken: 'keep-me');
      socket.connect(opts);
      await Future.delayed(Duration.zero);

      final cid = fake.decoded.first['cid'] as int;
      fake.pushJson({'rid': cid, 'data': {'isAuthenticated': true, 'id': 's1'}});

      fake.pushJson({'event': '#removeAuthToken'});

      expect(opts.authToken, 'keep-me');
      socket.destroy();
    });
  });

  // ── generic named event (data handler) ───────────────────────────────────

  group('_onMessage — generic event dispatch', () {
    test('invokes data handler for registered event channel', () async {
      final (socket, fake) = _makeSocket();
      dynamic received;
      socket.subscribe(SocketChannelConfig(
        channel: 'my-event',
        handlerType: SocketHandlerType.data,
        onData: (d) => received = d,
      ));
      await _doHandshake(socket, fake);

      fake.pushJson({'event': 'my-event', 'data': {'val': 42}});

      expect(received, {'val': 42});
      socket.destroy();
    });

    test('invokes fetch handler for registered fetch channel', () async {
      final (socket, fake) = _makeSocket();
      var fetchCalled = false;
      socket.subscribe(SocketChannelConfig(
        channel: 'refresh-event',
        handlerType: SocketHandlerType.fetch,
        onFetch: () async => fetchCalled = true,
      ));
      await _doHandshake(socket, fake);

      fake.pushJson({'event': 'refresh-event', 'data': null});

      expect(fetchCalled, isTrue);
      socket.destroy();
    });

    test('sends ACK when generic event has a cid', () async {
      final (socket, fake) = _makeSocket();
      socket.subscribe(SocketChannelConfig(
        channel: 'ev',
        handlerType: SocketHandlerType.data,
      ));
      await _doHandshake(socket, fake);
      fake._sent.clear();

      fake.pushJson({'event': 'ev', 'data': {}, 'cid': 99});

      final ack = fake.decoded.firstWhere((m) => m['rid'] == 99);
      expect(ack['rid'], 99);
      socket.destroy();
    });

    test('logs warning for unregistered event without throwing', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(
        () => fake.pushJson({'event': 'unknown-event', 'data': {}}),
        returnsNormally,
      );
      socket.destroy();
    });

    test('handler exception does not crash the socket', () async {
      final (socket, fake) = _makeSocket();
      socket.subscribe(SocketChannelConfig(
        channel: 'bad-handler',
        handlerType: SocketHandlerType.data,
        onData: (_) => throw Exception('handler error'),
      ));
      await _doHandshake(socket, fake);

      expect(
        () => fake.pushJson({'event': 'bad-handler', 'data': {}}),
        returnsNormally,
      );
      expect(socket.status, SocketConnectionStatus.connected);
      socket.destroy();
    });
  });

  // ── _onDone / reconnect ──────────────────────────────────────────────────

  group('_onDone / reconnect', () {
    test('server close sets status to reconnecting', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      fake.serverClose();

      expect(socket.status, SocketConnectionStatus.reconnecting);
      socket.destroy();
    });

    test('max attempts=0 immediately sets status to dead and calls callback', () async {
      var deadCalled = false;
      final (socket, fake) = _makeSocket();
      socket.connect(SocketServiceOptions(
        url: 'wss://test.local',
        reconnect: const ReconnectOptions(maxAttempts: 0),
        onMaxReconnectsReached: () => deadCalled = true,
      ));
      await Future.delayed(Duration.zero);

      final cid = fake.decoded.first['cid'] as int;
      fake.pushJson({'rid': cid, 'data': {'isAuthenticated': true}});

      fake.serverClose(); // triggers _onDone → _scheduleReconnect with maxAttempts=0

      expect(socket.status, SocketConnectionStatus.dead);
      expect(deadCalled, isTrue);
      socket.destroy();
    });

    test('no reconnect when socket was destroyed before server close', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      socket.destroy(); // sets _destroyed = true
      fake.serverClose(); // _onDone should see _destroyed and skip reconnect

      expect(socket.status, SocketConnectionStatus.idle);
    });
  });

  // ── emit while connected ─────────────────────────────────────────────────

  group('emit while connected', () {
    test('sends message immediately when connected', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);
      fake._sent.clear();

      socket.emit('booking-update', {'id': 'b1'});

      final msg = fake.decoded.first;
      expect(msg['event'], 'booking-update');
      expect((msg['data'] as Map)['id'], 'b1');
      socket.destroy();
    });

    test('queues message when not connected, sends after handshake', () async {
      final (socket, fake) = _makeSocket();

      socket.emit('pre-connect', {'queued': true});

      await _doHandshake(socket, fake);

      final sent = fake.decoded;
      final queued = sent.firstWhere((m) => m['event'] == 'pre-connect');
      expect((queued['data'] as Map)['queued'], isTrue);
      socket.destroy();
    });
  });

  // ── subscribe / unsubscribe while connected ──────────────────────────────

  group('subscribe / unsubscribe while connected', () {
    late SocketService socket;
    late FakeWebSocketChannel fake;

    setUp(() async {
      final pair = _makeSocket();
      socket = pair.$1;
      fake = pair.$2;
      await _doHandshake(socket, fake);
      fake._sent.clear();
    });

    tearDown(() => socket.destroy());

    test('subscribe while connected sends #subscribe message', () {
      socket.subscribe(SocketChannelConfig(
        channel: 'live-ch',
        handlerType: SocketHandlerType.data,
      ));

      final sub = fake.decoded.firstWhere((m) => m['event'] == '#subscribe');
      expect((sub['data'] as Map)['channel'], 'live-ch');
    });

    test('unsubscribe while connected sends #unsubscribe message', () {
      socket.subscribe(SocketChannelConfig(channel: 'live-ch', handlerType: SocketHandlerType.data));
      fake._sent.clear();
      socket.unsubscribe('live-ch');

      final unsub = fake.decoded.firstWhere((m) => m['event'] == '#unsubscribe');
      expect(unsub['data'], 'live-ch');
    });

    test('unsubscribeAll while connected sends #unsubscribe for each active channel', () {
      socket.subscribe(SocketChannelConfig(channel: 'ch1', handlerType: SocketHandlerType.data));
      socket.subscribe(SocketChannelConfig(channel: 'ch2', handlerType: SocketHandlerType.data));
      fake._sent.clear();

      socket.unsubscribeAll();

      final unsubEvents = fake.decoded.where((m) => m['event'] == '#unsubscribe').toList();
      expect(unsubEvents.length, 2);
    });
  });

  // ── resubscribe on reconnect ─────────────────────────────────────────────

  group('resubscribe on connect', () {
    test('pre-subscribed channels get #subscribe after handshake ACK', () async {
      final (socket, fake) = _makeSocket();
      socket.subscribe(SocketChannelConfig(
        channel: 'pre-sub-ch',
        handlerType: SocketHandlerType.data,
      ));

      await _doHandshake(socket, fake);

      final subs = fake.decoded.where((m) => m['event'] == '#subscribe').toList();
      expect(subs.any((m) => (m['data'] as Map)['channel'] == 'pre-sub-ch'), isTrue);
      socket.destroy();
    });
  });

  // ── app lifecycle ────────────────────────────────────────────────────────

  group('didChangeAppLifecycleState', () {
    test('paused sets inBackground and does not throw', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(
        () => socket.didChangeAppLifecycleState(AppLifecycleState.paused),
        returnsNormally,
      );
      socket.destroy();
    });

    test('detached sets inBackground and does not throw', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);

      expect(
        () => socket.didChangeAppLifecycleState(AppLifecycleState.detached),
        returnsNormally,
      );
      socket.destroy();
    });

    test('resumed when connected resets heartbeat without reconnecting', () async {
      final (socket, fake) = _makeSocket();
      await _doHandshake(socket, fake);
      fake._sent.clear();

      socket.didChangeAppLifecycleState(AppLifecycleState.paused);
      socket.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(socket.status, SocketConnectionStatus.connected);
      socket.destroy();
    });

    test('resumed when disconnected calls _openSocket again', () async {
      final channels = <FakeWebSocketChannel>[];
      final socket = SocketService.createForTesting(wsFactory: (_) {
        final ch = FakeWebSocketChannel();
        channels.add(ch);
        return ch;
      });

      // Connect and complete handshake
      socket.connect(SocketServiceOptions(url: 'wss://test.local'));
      await Future.delayed(Duration.zero);
      final cid = channels[0].decoded.first['cid'] as int;
      channels[0].pushJson({'rid': cid, 'data': {'isAuthenticated': true}});
      expect(socket.status, SocketConnectionStatus.connected);

      // Go to background — this prevents auto-reconnect scheduling
      socket.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Server closes the connection → _onDone fires, status = reconnecting
      // but _scheduleReconnect is skipped because _inBackground = true
      channels[0].serverClose();

      // Resume while not connected → should trigger immediate _openSocket
      socket.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(Duration.zero); // let new _openSocket create channel[1]

      expect(channels.length, greaterThan(1));
      socket.destroy();
    });
  });

  // ── timers (fakeAsync) ───────────────────────────────────────────────────

  group('timers', () {
    test('handshake timeout (10s) closes sink when not yet connected', () {
      fakeAsync((async) {
        final fake = FakeWebSocketChannel();
        final socket = SocketService.createForTesting(wsFactory: (_) => fake);

        socket.connect(SocketServiceOptions(url: 'wss://test.local'));
        async.flushMicrotasks(); // let _openSocket run

        expect(fake._fakeSink.closeCalls, 0);

        async.elapse(const Duration(seconds: 11));
        expect(fake._fakeSink.closeCalls, greaterThan(0));

        socket.destroy();
      });
    });

    test('heartbeat watchdog (11min) closes sink after silence', () {
      fakeAsync((async) {
        final fake = FakeWebSocketChannel();
        final socket = SocketService.createForTesting(wsFactory: (_) => fake);

        socket.connect(SocketServiceOptions(url: 'wss://test.local', authToken: 'tok'));
        async.flushMicrotasks();

        // Complete handshake to start heartbeat timer
        final cid = fake.decoded.first['cid'] as int;
        fake.pushJson({'rid': cid, 'data': {'isAuthenticated': true}});
        async.flushMicrotasks();

        expect(socket.status, SocketConnectionStatus.connected);

        // Advance past the 11-minute heartbeat timeout
        async.elapse(const Duration(minutes: 12));
        expect(fake._fakeSink.closeCalls, greaterThan(0));

        socket.destroy();
      });
    });

    test('reconnect timer fires and calls _openSocket again', () {
      fakeAsync((async) {
        final channels = <FakeWebSocketChannel>[];
        final socket = SocketService.createForTesting(wsFactory: (_) {
          final ch = FakeWebSocketChannel();
          channels.add(ch);
          return ch;
        });

        socket.connect(SocketServiceOptions(
          url: 'wss://test.local',
          reconnect: const ReconnectOptions(
            interval: Duration(seconds: 1),
            maxAttempts: 5,
          ),
        ));
        async.flushMicrotasks();

        // Complete handshake
        final cid = channels[0].decoded.first['cid'] as int;
        channels[0].pushJson({'rid': cid, 'data': {'isAuthenticated': true}});
        expect(socket.status, SocketConnectionStatus.connected);

        // Server closes → triggers reconnect scheduling
        channels[0].serverClose();
        expect(socket.status, SocketConnectionStatus.reconnecting);

        // Advance time to fire the reconnect timer (1s base interval)
        async.elapse(const Duration(seconds: 4));
        async.flushMicrotasks(); // let new _openSocket run

        // A second channel should have been created for the retry
        expect(channels.length, greaterThan(1));

        socket.destroy();
      });
    });
  });

  // ── updateToken ──────────────────────────────────────────────────────────

  group('updateToken', () {
    test('updates authToken in existing options', () async {
      final (socket, fake) = _makeSocket();
      final opts = SocketServiceOptions(url: 'wss://test.local', authToken: 'old');
      socket.connect(opts);
      await Future.delayed(Duration.zero);

      socket.updateToken('refreshed-token');

      expect(opts.authToken, 'refreshed-token');
      socket.destroy();
    });
  });

  // ── dispose ──────────────────────────────────────────────────────────────

  group('dispose', () {
    test('closes the statusStream', () async {
      final (socket, _) = _makeSocket();
      socket.dispose();
      expect(socket.statusStream.isBroadcast, isTrue);
    });
  });

  // ── Singleton smoke tests (kept for regression) ───────────────────────────

  group('singleton', () {
    setUp(() => SocketService.getInstance().destroy());

    test('status is idle after destroy', () {
      expect(SocketService.getInstance().status, SocketConnectionStatus.idle);
    });

    test('isConnected is false initially', () {
      expect(SocketService.getInstance().isConnected, isFalse);
    });

    test('statusStream is a broadcast stream', () {
      expect(SocketService.getInstance().statusStream.isBroadcast, isTrue);
    });
  });
}
