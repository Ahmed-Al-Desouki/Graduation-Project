import 'package:get_it/get_it.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_local_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_local_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/data_sources/medical_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/medical_remote_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/repositories/medical_repository_impl.dart';
import 'package:graduation_project/features/booking/data/repositories/payment_repository_impl.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';
import 'package:graduation_project/features/booking/domain/repositories/payment_repository.dart';
import 'package:graduation_project/features/booking/domain/use_cases/GetDoctorAppointmentsUseCase.dart';
import 'package:graduation_project/features/booking/domain/use_cases/GetPatientAppointmentsUseCase.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_custom_hours_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_day_off_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_prescription_items_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/block_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/cancel_by_patient_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/creat_chat_room_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_appointment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_payment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/delete_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_appointment_full_details_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_medical_record_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/open_access_for_medical_history_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/remove_exception_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/remove_working_day_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/restore_blocked_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/save_medical_record_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/exam_session_cubit/exam_session_cubit.dart';
import 'package:hive/hive.dart';
import 'domain/repositories/i_booking_repository.dart';
import 'data/repositories/booking_repository_impl.dart';
import 'domain/use_cases/create_schedule_use_case.dart';
import 'domain/use_cases/generate_slots_use_case.dart';
import 'domain/use_cases/get_active_schedule_use_case.dart';
import 'presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';

final sl = GetIt.instance;

Future<void> initBookingInjection() async {
  final bookingBox = await Hive.openBox('booking_box');

  sl.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(bookingBox),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<MedicalRemoteDataSource>(
    () => MedicalRemoteDataSourceImpl(sl()),
  );

  // 2. Repository
  sl.registerLazySingleton<IBookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<MedicalRepository>(
    () => MedicalRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => CreateScheduleUseCase(sl()));
  sl.registerLazySingleton(() => GenerateSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveScheduleUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorSlotsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAppointmentStatusUseCase(sl()));

  sl.registerLazySingleton(() => GetMedicalRecordUseCase(sl()));
  sl.registerLazySingleton(() => SaveMedicalRecordUseCase(sl()));
  sl.registerLazySingleton(() => CreatePrescriptionUseCase(sl()));

  sl.registerLazySingleton(() => CreateManualSlotUseCase(sl()));
  sl.registerLazySingleton(() => BookFollowUpUseCase(sl()));
  sl.registerLazySingleton(() => BlockSlotUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSlotUseCase(sl()));
  sl.registerLazySingleton(() => RestoreBlockedSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetPrescriptionUseCase(sl()));
  sl.registerLazySingleton(() => AddPrescriptionItemsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => CreateAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomHoursUseCase(sl()));
  sl.registerLazySingleton(() => AddDayOffUseCase(sl()));
  sl.registerLazySingleton(() => RemoveExceptionUseCase(sl()));
  sl.registerLazySingleton(() => RemoveWorkingDayUseCase(sl()));
  sl.registerLazySingleton(() => GetAppointmentFullDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetPatientAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => CancelByPatientUseCase(sl()));
  sl.registerLazySingleton(() => OpenAccessForMedicalHistoryUseCase(sl()));
  sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));

  sl.registerFactory(
    () => ScheduleManagementCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory(() => BookingCalendarCubit(sl()));
  sl.registerFactory(
    () => ExamSessionCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  sl.registerFactory(
    () => AppointmentActionCubit(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(
    () => AppointmentsCenterCubit(
      getDoctorAppointmentsUseCase: sl(),
      getPatientAppointmentsUseCase: sl(),
      updateStatusUseCase: sl(),
    ),
  );
}
