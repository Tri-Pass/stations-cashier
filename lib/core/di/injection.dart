import 'package:get_it/get_it.dart';
import 'package:cashier/core/l10n/locale_notifier.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/network/socket_service.dart';
import 'package:cashier/core/storage/local_storage.dart';
import 'package:cashier/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cashier/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashier/features/auth/domain/usecases/login_usecase.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Locale
  final localeNotifier = LocaleNotifier();
  await localeNotifier.init();
  sl.registerSingleton(localeNotifier);

  // Core infrastructure
  sl.registerLazySingleton(() => LocalStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => SocketService.getInstance());

  // Auth feature
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(loginUseCase: sl(), authRepository: sl(), socketService: sl()),
  );
}
