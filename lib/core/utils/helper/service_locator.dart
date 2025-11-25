import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo_impl.dart';
import 'package:graduation_project/features/auth/data/services/auth_web_service.dart';
import 'package:graduation_project/features/reminder/data/services/reminder_web_service.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/medical_history/data/repository/patient_repo_impl.dart';
import 'package:graduation_project/features/medical_history/data/service/patient_web_service.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
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

  getIt.registerLazySingleton<ReminderWebService>(
    () => ReminderWebService(getIt<ApiService>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepositoryimpl>(
    () => AuthRepositoryimpl(getIt<AuthWebServices>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepositoryimpl>()),
  );

  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(getIt<ReminderWebService>()),
  );

  getIt.registerFactory<ReminderCubit>(
    () => ReminderCubit(getIt<ReminderRepository>()),);

  getIt.registerLazySingleton<SessionManager>(
    () => SessionManager(getIt<AuthRepositoryimpl>()),
  );

  getIt.registerLazySingleton<PatientWebServices>(
    () => PatientWebServices(getIt<ApiService>()),
  );

  // 2. Patient Repository
  getIt.registerLazySingleton<PatientRepositoryImpl>(
    () => PatientRepositoryImpl(getIt<PatientWebServices>()),
  );

  // 3. Patient Cubit
  getIt.registerFactory<PatientProfileCubit>(
    () => PatientProfileCubit(getIt<PatientRepositoryImpl>()),
  );
}
