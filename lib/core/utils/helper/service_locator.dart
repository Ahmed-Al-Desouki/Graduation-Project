import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
import 'package:graduation_project/features/auth/data/services/auth_web_service.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Dio instance
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );

  // ApiService
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(
      baseUrl: 'https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/',
    ),
  );

  // Web Services
  getIt.registerLazySingleton<AuthWebServices>(
    () => AuthWebServices(getIt<ApiService>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepositoryimpl>(
    () => AuthRepositoryimpl(getIt<AuthWebServices>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepositoryimpl>()),
  );
}
