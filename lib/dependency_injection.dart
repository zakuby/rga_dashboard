import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_widgets_usecase.dart';
import 'features/dashboard/domain/usecases/reorder_widgets_usecase.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initializes all dependencies.
Future<void> initDependencies() async {
  // ==================== Auth Feature ====================

  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckAuthStatusUseCase(getIt()));

  // Cubit
  getIt.registerFactory(
    () => AuthCubit(
      loginUseCase: getIt(),
      logoutUseCase: getIt(),
      checkAuthStatusUseCase: getIt(),
    ),
  );

  // ==================== Dashboard Feature ====================

  // Data Sources
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(localDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetWidgetsUseCase(getIt()));
  getIt.registerLazySingleton(() => ReorderWidgetsUseCase(getIt()));

  // Cubit
  getIt.registerFactory(
    () => DashboardCubit(
      getWidgetsUseCase: getIt(),
      reorderWidgetsUseCase: getIt(),
    ),
  );
}
