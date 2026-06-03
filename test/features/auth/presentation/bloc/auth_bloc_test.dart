import 'package:bloc_test/bloc_test.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/network/socket_service.dart';
import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashier/features/auth/domain/usecases/login_usecase.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSocketService extends Mock implements SocketService {}

const _driver = DriverEntity(
  id: 'd1',
  name: 'Ahmed',
  phone: '0600000001',
  taxiNumber: 'T1',
  plateNumber: 'ABC-123',
  balance: 100.0,
);

void main() {
  late MockAuthRepository authRepository;
  late MockLoginUseCase loginUseCase;
  late MockSocketService socketService;

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        authRepository: authRepository,
        socketService: socketService,
      );

  setUpAll(() {
    registerFallbackValue(SocketServiceOptions(url: ''));
  });

  setUp(() {
    authRepository = MockAuthRepository();
    loginUseCase = MockLoginUseCase();
    socketService = MockSocketService();

    when(() => socketService.status).thenReturn(SocketConnectionStatus.idle);
    when(() => socketService.connect(any())).thenAnswer((_) {});
    when(() => socketService.destroy()).thenAnswer((_) {});
  });

  group('AuthCheckEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when not authenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isAuthenticated()).thenAnswer((_) async => false);
      },
      act: (b) => b.add(AuthCheckEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when authenticated with valid profile',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authRepository.getProfile()).thenAnswer((_) async => _driver);
        when(() => authRepository.getToken()).thenAnswer((_) async => 'token123');
      },
      act: (b) => b.add(AuthCheckEvent()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
      verify: (_) {
        verify(() => authRepository.isAuthenticated()).called(1);
        verify(() => authRepository.getProfile()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] and connects socket when token available',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authRepository.getProfile()).thenAnswer((_) async => _driver);
        when(() => authRepository.getToken()).thenAnswer((_) async => 'mytoken');
      },
      act: (b) => b.add(AuthCheckEvent()),
      verify: (_) {
        verify(() => socketService.connect(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'skips connect when socket already connected',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(() => authRepository.getProfile()).thenAnswer((_) async => _driver);
        when(() => socketService.status)
            .thenReturn(SocketConnectionStatus.connected);
      },
      act: (b) => b.add(AuthCheckEvent()),
      verify: (_) {
        verifyNever(() => socketService.connect(any()));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] and calls logout on exception',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isAuthenticated()).thenThrow(Exception('error'));
        when(() => authRepository.logout()).thenAnswer((_) async {});
      },
      act: (b) => b.add(AuthCheckEvent()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(() => authRepository.logout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits nothing extra when already authenticated',
      build: buildBloc,
      seed: () => AuthAuthenticated(_driver),
      act: (b) => b.add(AuthCheckEvent()),
      expect: () => [],
    );
  });

  group('AuthLoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on successful login',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase('0600000001', 'pass123'))
            .thenAnswer((_) async => _driver);
        when(() => authRepository.getProfile()).thenAnswer((_) async => _driver);
        when(() => authRepository.getToken()).thenAnswer((_) async => 'token');
      },
      act: (b) => b.add(AuthLoginEvent('0600000001', 'pass123')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] with message on ApiException',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any(), any()))
            .thenThrow(ApiException('Identifiants invalides', 401));
      },
      act: (b) => b.add(AuthLoginEvent('bad', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((e) => e.message, 'message', 'Identifiants invalides'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, AuthError] with generic message on unexpected exception',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any(), any())).thenThrow(Exception('timeout'));
      },
      act: (b) => b.add(AuthLoginEvent('0600', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (e) => e.message,
          'message',
          'Erreur de connexion au serveur',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] and connects socket after login',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any(), any())).thenAnswer((_) async => _driver);
        when(() => authRepository.getProfile()).thenAnswer((_) async => _driver);
        when(() => authRepository.getToken()).thenAnswer((_) async => 'tok');
      },
      act: (b) => b.add(AuthLoginEvent('0600', 'pass')),
      verify: (_) {
        verify(() => socketService.connect(any())).called(1);
      },
    );
  });

  group('AuthEvent props', () {
    test('AuthCheckEvent.props is empty (via AuthEvent)', () {
      expect(AuthCheckEvent().props, isEmpty);
    });

    test('AuthLoginEvent.props contains phone and password', () {
      final event = AuthLoginEvent('0600000001', 'pass123');
      expect(event.props, ['0600000001', 'pass123']);
    });

    test('two AuthLoginEvents with same credentials are equal', () {
      expect(
        AuthLoginEvent('0600', 'pass'),
        equals(AuthLoginEvent('0600', 'pass')),
      );
    });

    test('two AuthLoginEvents with different credentials are not equal', () {
      expect(
        AuthLoginEvent('0600', 'pass1'),
        isNot(equals(AuthLoginEvent('0600', 'pass2'))),
      );
    });
  });

  group('AuthLogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] and destroys socket on logout',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.logout()).thenAnswer((_) async {});
      },
      act: (b) => b.add(AuthLogoutEvent()),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(() => socketService.destroy()).called(1);
        verify(() => authRepository.logout()).called(1);
      },
    );
  });
}
