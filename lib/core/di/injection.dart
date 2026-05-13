import 'package:get_it/get_it.dart';
import 'package:cashier/core/l10n/locale_notifier.dart';
import 'package:cashier/core/theme/theme_notifier.dart';
import 'package:cashier/core/notifiers/booking_refresh_notifier.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/core/network/connectivity_service.dart';
import 'package:cashier/core/network/socket_service.dart';
import 'package:cashier/core/storage/local_storage.dart';

// Auth
import 'package:cashier/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cashier/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashier/features/auth/domain/usecases/login_usecase.dart';
import 'package:cashier/features/auth/presentation/bloc/auth_bloc.dart';

// Lines
import 'package:cashier/features/lines/data/datasources/lines_remote_datasource.dart';
import 'package:cashier/features/lines/data/repositories/lines_repository_impl.dart';
import 'package:cashier/features/lines/domain/repositories/lines_repository.dart';
import 'package:cashier/features/lines/domain/usecases/get_lines_usecase.dart';
import 'package:cashier/features/lines/domain/usecases/get_line_queue_usecase.dart';

// Booking
import 'package:cashier/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:cashier/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:cashier/features/booking/domain/repositories/booking_repository.dart';
import 'package:cashier/features/booking/domain/usecases/create_booking_usecase.dart';

// Drivers
import 'package:cashier/features/drivers/data/datasources/driver_remote_datasource.dart';

// Cashouts
import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/repositories/cashout_repository_impl.dart';
import 'package:cashier/features/cashouts/data/repositories/ticket_repository_impl.dart';
import 'package:cashier/features/cashouts/domain/repositories/cashout_repository.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_cashouts_summary_usecase.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_driver_tickets_usecase.dart';
import 'package:cashier/features/cashouts/domain/usecases/cashout_ticket_usecase.dart';

// Passengers
import 'package:cashier/features/passengers/data/datasources/passenger_remote_datasource.dart';
import 'package:cashier/features/passengers/data/repositories/passenger_repository_impl.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/get_passenger_by_nfc_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/link_nfc_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/recharge_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/nfc_topup_usecase.dart';
import 'package:cashier/features/passengers/domain/usecases/phone_topup_usecase.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Locale
  final localeNotifier = LocaleNotifier();
  await localeNotifier.init();
  sl.registerSingleton(localeNotifier);

  // Theme
  final themeNotifier = ThemeNotifier();
  await themeNotifier.init();
  sl.registerSingleton(themeNotifier);

  // Core infrastructure
  sl.registerLazySingleton(() => LocalStorage());
  sl.registerLazySingleton(() => BookingRefreshNotifier());
  sl.registerLazySingleton(() => ApiClient(sl()));
  sl.registerLazySingleton(() => SocketService.getInstance());
  sl.registerLazySingleton(() => ConnectivityService());

  // Auth feature
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(loginUseCase: sl(), authRepository: sl(), socketService: sl()),
  );

  // Lines feature
  sl.registerLazySingleton(() => LinesRemoteDataSource(sl()));
  sl.registerLazySingleton<LinesRepository>(() => LinesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetLinesUseCase(sl()));
  sl.registerLazySingleton(() => GetLineQueueUseCase(sl()));

  // Booking feature
  sl.registerLazySingleton(() => BookingRemoteDataSource(sl()));
  sl.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));

  // Drivers feature
  sl.registerLazySingleton(() => DriverRemoteDataSource(sl()));

  // Cashouts feature
  sl.registerLazySingleton(() => CashoutRemoteDataSource(sl()));
  sl.registerLazySingleton<CashoutRepository>(() => CashoutRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCashoutsSummaryUseCase(sl()));

  // Tickets feature
  sl.registerLazySingleton(() => TicketRemoteDataSource(sl()));
  sl.registerLazySingleton<TicketRepository>(() => TicketRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetDriverTicketsUseCase(sl()));
  sl.registerLazySingleton(() => CashoutTicketUseCase(sl()));

  // Passengers feature
  sl.registerLazySingleton(() => PassengerRemoteDataSource(sl()));
  sl.registerLazySingleton<PassengerRepository>(() => PassengerRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetPassengerByNfcUseCase(sl()));
  sl.registerLazySingleton(() => LinkNfcUseCase(sl()));
  sl.registerLazySingleton(() => RechargeUseCase(sl()));
  sl.registerLazySingleton(() => NfcTopupUseCase(sl()));
  sl.registerLazySingleton(() => PhoneTopupUseCase(sl()));
}
