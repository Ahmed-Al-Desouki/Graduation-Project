import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
import 'package:graduation_project/features/booking/booking_injection.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_patient_profile_for_doctor_use_case.dart';
import 'package:graduation_project/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:graduation_project/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:graduation_project/features/chat/data/repositories/mock_chat_repository.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_my_chat_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/mark_as_read_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/send_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/upload_chat_file_use_case.dart';
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
import 'package:graduation_project/features/doctor_profile/data/data_sources/doctor_profile_remote_data_source.dart';
import 'package:graduation_project/features/doctor_profile/data/data_sources/doctor_profile_remote_data_source_impl.dart';
import 'package:graduation_project/features/doctor_profile/data/repositories/doctor_real_profile_repository_impl.dart';
import 'package:graduation_project/features/doctor_profile/domain/repositories/doctor_real_profile_repository.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/delete_achievement_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_doctor_profile_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_doctor_slot_config_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/get_public_doctor_profile_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/replace_verification_document_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_achievement_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_basic_info_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_profile_image_use_case.dart';
import 'package:graduation_project/features/doctor_profile/domain/use_cases/update_real_location_use_case.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/home/data/repos/home_repo_impl.dart';
import 'package:graduation_project/features/home/data/service/home_web_service.dart';
import 'package:graduation_project/features/home/domain/repos/home_repo.dart';
import 'package:graduation_project/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:graduation_project/features/medical_history/data/repository/medical_history_qr_repo.dart';
import 'package:graduation_project/features/medical_history/data/service/medical_history_qr_service.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:graduation_project/features/notification/data/repos/notification_repository_impl.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
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
import 'package:graduation_project/features/review/data/repos/review_repo_impl.dart';
import 'package:graduation_project/features/review/data/web_services/review_web_service.dart';
import 'package:graduation_project/features/review/domain/repos/review_repo.dart';
import 'package:graduation_project/features/review/presentation/review_cubit/review_cubit.dart';
import 'package:graduation_project/features/patient_profile/data/data_sources/patient_account_profile_remote_data_source.dart';
import 'package:graduation_project/features/patient_profile/data/data_sources/patient_account_profile_remote_data_source_impl.dart';
import 'package:graduation_project/features/patient_profile/data/repositories/patient_account_profile_repository_impl.dart';
import 'package:graduation_project/features/patient_profile/domain/repositories/patient_account_profile_repository.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/get_patient_account_profile_use_case.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/update_patient_onboarding_profile_use_case.dart';
import 'package:graduation_project/features/patient_profile/domain/use_cases/update_patient_profile_image_use_case.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:graduation_project/features/search/data/data_sources/search_remote_data_source_impl.dart';
import 'package:graduation_project/features/search/data/repositories/search_repo_impl.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_specializations_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_top_rated_doctors_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/search_doctors_use_case.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/support_tickets/data/data_sources/support_remote_data_source.dart';
import 'package:graduation_project/features/support_tickets/data/repositories/support_repository_impl.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/create_ticket_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/get_my_tickets_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/get_ticket_messages_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/send_ticket_message_use_case.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/ticket_chat_cubit/ticket_chat_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
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

  // 1. SignalR Service (بما إنها LazySingleton فهي موجودة عندك فعلاً)
  getIt.registerLazySingleton<SignalRService>(() => SignalRService());

  getIt.registerLazySingleton<LocalOccurrenceDataSource>(
    () => LocalOccurrenceDataSource(),
  );

  getIt.registerLazySingleton<AuthWebServices>(
    () => AuthWebServices(getIt<ApiService>()),
  );

  // --- Notifications Feature ---

  // 1. Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<ApiService>()),
  );

  // 2. Cubit
  // بنسجله كـ LazySingleton عشان يفضل محتفظ بالحالة والاتصال طول ما الأبب مفتوح
  getIt.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getIt<NotificationRepository>(),
      getIt<SignalRService>(),
    ),
  );

  getIt.registerLazySingleton<ReminderWebService>(
    () => ReminderWebService(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<PatientWebServices>(
    () => PatientWebServices(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<PatientAccountProfileRemoteDataSource>(
    () => PatientAccountProfileRemoteDataSourceImpl(getIt<ApiService>()),
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

  getIt.registerLazySingleton<PatientAccountProfileRepository>(
    () => PatientAccountProfileRepositoryImpl(
      getIt<PatientAccountProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<MedicalHistoryQrRepository>(
    () => MedicalHistoryQrRepository(getIt<MedicalHistoryQrService>()),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeWebService>()),
  );

  getIt.registerLazySingleton<ReviewWebService>(
    () => ReviewWebService(getIt<ApiService>()),
  );

  // Repository
  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(getIt<ReviewWebService>()),
  );

  // Cubit
  getIt.registerFactory<ReviewCubit>(
    () => ReviewCubit(getIt<ReviewRepository>()),
  );

  // Data
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt()),
  );

  // UseCases
  getIt.registerLazySingleton(() => GetMessagesUseCase(getIt()));
  getIt.registerLazySingleton(() => SendMessageUseCase(getIt()));
  getIt.registerLazySingleton(() => UploadChatFileUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMyChatsUseCase(getIt()));
  getIt.registerLazySingleton<GetPatientProfileForDoctorUseCase>(
    () => GetPatientProfileForDoctorUseCase(getIt()),
  );

  getIt.registerLazySingleton<GetPatientAccountProfileUseCase>(
    () => GetPatientAccountProfileUseCase(
      getIt<PatientAccountProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdatePatientOnboardingProfileUseCase>(
    () => UpdatePatientOnboardingProfileUseCase(
      getIt<PatientAccountProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdatePatientProfileImageUseCase>(
    () => UpdatePatientProfileImageUseCase(
      getIt<PatientAccountProfileRepository>(),
    ),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<AuthRepositoryimpl>()),
  );

  getIt.registerFactory<ReminderCubit>(
    () => ReminderCubit(getIt<ReminderRepository>()),
  );

  getIt.registerFactory<PatientProfileCubit>(
    () => PatientProfileCubit(
      getIt<PatientRepositoryImpl>(),
      getIt<GetPatientProfileForDoctorUseCase>(),
    ),
  );

  getIt.registerFactory<PatientAccountProfileCubit>(
    () => PatientAccountProfileCubit(
      getIt<GetPatientAccountProfileUseCase>(),
      getIt<UpdatePatientOnboardingProfileUseCase>(),
      getIt<UpdatePatientProfileImageUseCase>(),
    ),
  );

  getIt.registerFactory<MedicalqrCubit>(
    () => MedicalqrCubit(getIt<MedicalHistoryQrRepository>()),
  );

  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt<GetMyChatsUseCase>()));

  getIt.registerLazySingleton<MarkAsReadUseCase>(
    () => MarkAsReadUseCase(getIt()),
  );

  getIt.registerFactory<ChatDetailsCubit>(
    () => ChatDetailsCubit(
      getIt<GetMessagesUseCase>(),
      getIt<SendMessageUseCase>(),
      getIt<UploadChatFileUseCase>(),
      getIt<MarkAsReadUseCase>(),
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
      getIt<GetDoctorProfileUseCase>(),
      getIt<UpdateBasicInfoUseCase>(),
      getIt<ReplaceVerificationDocumentUseCase>(),
    ),
  );

  getIt.registerLazySingleton<DoctorProfileRemoteDataSource>(
    () => DoctorProfileRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<DoctorRealProfileRepository>(
    () =>
        DoctorRealProfileRepositoryImpl(getIt<DoctorProfileRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetDoctorProfileUseCase>(
    () => GetDoctorProfileUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateBasicInfoUseCase>(
    () => UpdateBasicInfoUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateRealLocationUseCase>(
    () => UpdateRealLocationUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<ReplaceVerificationDocumentUseCase>(
    () => ReplaceVerificationDocumentUseCase(
      getIt<DoctorRealProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateAchievementUseCase>(
    () => UpdateAchievementUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<DeleteAchievementUseCase>(
    () => DeleteAchievementUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<GetDoctorSlotConfigUseCase>(
    () => GetDoctorSlotConfigUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerLazySingleton<GetPublicDoctorProfileUseCase>(
    () => GetPublicDoctorProfileUseCase(getIt<DoctorRealProfileRepository>()),
  );

  getIt.registerFactory<DoctorRealProfileCubit>(
    () => DoctorRealProfileCubit(
      getIt<GetDoctorProfileUseCase>(),
      getIt<UpdateBasicInfoUseCase>(),
      getIt<UpdateRealLocationUseCase>(),
      getIt<ReplaceVerificationDocumentUseCase>(),
      getIt<UpdateAchievementUseCase>(),
      getIt<DeleteAchievementUseCase>(),
      getIt<UpdateProfileImageUseCase>(),
      getIt<GetDoctorSlotConfigUseCase>(),
      getIt<GetPublicDoctorProfileUseCase>(),
      getIt<AddAchievementUseCase>(),
    ),
  );

  getIt.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // 3. Repositories
  getIt.registerLazySingleton<TicketRepository>(
    () =>
        TicketRepositoryImpl(remoteDataSource: getIt<TicketRemoteDataSource>()),
  );

  // 4. Use Cases
  getIt.registerLazySingleton(
    () => GetMyTicketsUseCase(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateTicketUseCase(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTicketMessagesUseCase(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton(
    () => SendTicketMessageUseCase(getIt<TicketRepository>()),
  );

  // 5. Cubits (نستخدم Factory عشان الـ Cubit يتكريت جديد مع كل شاشة)
  getIt.registerFactory(
    () => TicketChatCubit(
      getMessagesUseCase: getIt<GetTicketMessagesUseCase>(),
      sendMessageUseCase: getIt<SendTicketMessageUseCase>(),
      signalRService: getIt<SignalRService>(),
    ),
  );

  getIt.registerFactory(
    () => TicketsCubit(
      getIt<GetMyTicketsUseCase>(),
      getIt<CreateTicketUseCase>(),
    ),
  );
}
