import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
import 'package:graduation_project/features/booking/booking_injection.dart';
import 'package:graduation_project/features/chat/data/repositories/mock_chat_repository.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_chat_previews_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/send_messages_use_case.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_details_cubit/chat_details_cubit.dart';
import 'package:graduation_project/features/doctor_home/data/data_sources/doctor_completion_profile_remote_data_source.dart';
import 'package:graduation_project/features/doctor_home/data/data_sources/doctor_completion_profile_remote_data_source_impl.dart';
import 'package:graduation_project/features/doctor_home/data/repositories/doctor_profile_repository_impl.dart';
import 'package:graduation_project/features/doctor_home/domain/repositories/doctor_profile_repository.dart';
import 'package:graduation_project/features/doctor_home/domain/use_cases/add_achievement_use_case.dart';
import 'package:graduation_project/features/doctor_home/domain/use_cases/complete_profile_use_case.dart';
import 'package:graduation_project/features/doctor_home/domain/use_cases/update_location_use_case.dart';
import 'package:graduation_project/features/doctor_home/domain/use_cases/upload_verification_document_use_case.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/data/repositories/doctor_real_profile_repository_impl.dart';
import 'package:graduation_project/features/doctor_profile/domain/repositories/doctor_real_profile_repository.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_doctor_profile_use_case.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/home/data/repos/home_repo_impl.dart';
import 'package:graduation_project/features/home/data/service/home_web_service.dart';
import 'package:graduation_project/features/home/domain/repos/home_repo.dart';
import 'package:graduation_project/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:graduation_project/features/medical_history/data/repository/medical_history_qr_repo.dart';
import 'package:graduation_project/features/medical_history/data/service/medical_history_qr_service.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:graduation_project/features/reminder/data/data_sources/local_occurrence_data_source.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo_impl.dart';
import 'package:graduation_project/features/auth/data/services/auth_web_service.dart';
import 'package:graduation_project/features/reminder/data/services/reminder_web_service.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/medical_history/data/repository/patient_repo/patient_repo_impl.dart';
import 'package:graduation_project/features/medical_history/data/service/patient_web_service.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:graduation_project/features/search/data/data_sources/search_remote_data_source_impl.dart';
import 'package:graduation_project/features/search/data/repositories/search_repo_impl.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_specializations_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_top_rated_doctors_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/search_doctors_use_case.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  getIt.registerLazySingleton<ApiService>(
    () => ApiService(baseUrl: '$apiBaseUrl/api/'),
  );

  getIt.registerLazySingleton<SessionManager>(
    () => SessionManager(getIt<AuthRepositoryimpl>()),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.createInstance()),
  );

  getIt.registerLazySingleton<LocalOccurrenceDataSource>(
    () => LocalOccurrenceDataSource(),
  );

  getIt.registerLazySingleton<AuthWebServices>(
    () => AuthWebServices(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<ReminderWebService>(
    () => ReminderWebService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<PatientWebServices>(
    () => PatientWebServices(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<MedicalHistoryQrService>(
    () => MedicalHistoryQrService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<HomeWebService>(
    () => HomeWebService(getIt<ApiService>()),
  );

  await initBookingInjection();

  getIt.registerLazySingleton<AuthRepositoryimpl>(
    () => AuthRepositoryimpl(getIt<AuthWebServices>()),
  );

  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      getIt<ReminderWebService>(),
      getIt<LocalOccurrenceDataSource>(),
    ),
  );

  getIt.registerLazySingleton<PatientRepositoryImpl>(
    () => PatientRepositoryImpl(getIt<PatientWebServices>()),
  );

  getIt.registerLazySingleton<MedicalHistoryQrRepository>(
    () => MedicalHistoryQrRepository(getIt<MedicalHistoryQrService>()),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeWebService>()),
  );

  getIt.registerLazySingleton<IChatRepository>(() => MockChatRepository());

  getIt.registerLazySingleton(
    () => GetChatPreviewsUseCase(getIt<IChatRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetMessagesUseCase(getIt<IChatRepository>()),
  );
  getIt.registerLazySingleton(
    () => SendMessageUseCase(getIt<IChatRepository>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepositoryimpl>()),
  );

  getIt.registerFactory<ReminderCubit>(
    () => ReminderCubit(getIt<ReminderRepository>()),
  );

  getIt.registerFactory<PatientProfileCubit>(
    () => PatientProfileCubit(getIt<PatientRepositoryImpl>()),
  );

  getIt.registerFactory<MedicalqrCubit>(
    () => MedicalqrCubit(getIt<MedicalHistoryQrRepository>()),
  );

  getIt.registerFactory<ChatCubit>(
    () => ChatCubit(getIt<GetChatPreviewsUseCase>()),
  );

  getIt.registerFactory(
    () => ChatDetailsCubit(
      getIt<GetMessagesUseCase>(),
      getIt<SendMessageUseCase>(),
    ),
  );

  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepository>()));

  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<SearchRepo>(
    () =>
        SearchRepositoryImpl(remoteDataSource: getIt<SearchRemoteDataSource>()),
  );

  getIt.registerLazySingleton(() => SearchDoctorsUseCase(getIt<SearchRepo>()));

  getIt.registerLazySingleton(
    () => GetSpecializationsUseCase(getIt<SearchRepo>()),
  );
  getIt.registerLazySingleton(
    () => GetTopRatedDoctorsUseCase(getIt<SearchRepo>()),
  );

  getIt.registerFactory(
    () => SearchCubit(
      getIt<SearchDoctorsUseCase>(),
      getIt<GetSpecializationsUseCase>(),
      getIt<GetTopRatedDoctorsUseCase>(),
    ),
  );

  getIt.registerLazySingleton<DoctorCompletionProfileRemoteDataSource>(
    () => DoctorCompletionProfileRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<DoctorProfileRepository>(
    () => DoctorProfileRepositoryImpl(
      getIt<DoctorCompletionProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CompleteProfileUseCase>(
    () => CompleteProfileUseCase(getIt<DoctorProfileRepository>()),
  );

  getIt.registerLazySingleton<UploadVerificationDocumentUseCase>(
    () => UploadVerificationDocumentUseCase(getIt<DoctorProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateLocationUseCase>(
    () => UpdateLocationUseCase(getIt<DoctorProfileRepository>()),
  );

  getIt.registerLazySingleton<AddAchievementUseCase>(
    () => AddAchievementUseCase(getIt<DoctorProfileRepository>()),
  );

  getIt.registerFactory<DoctorProfileCubit>(
    () => DoctorProfileCubit(
      getIt<CompleteProfileUseCase>(),
      getIt<UploadVerificationDocumentUseCase>(),
      getIt<UpdateLocationUseCase>(),
      getIt<AddAchievementUseCase>(),
      getIt<DoctorProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<DoctorRealProfileRepository>(
    () => DoctorRealProfileRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<GetDoctorProfileUseCase>(
    () => GetDoctorProfileUseCase(getIt()),
  );

  getIt.registerFactory<DoctorRealProfileCubit>(
    () => DoctorRealProfileCubit(getIt()),
  );
}
