// import 'package:hive/hive.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'data/data_sources/booking_local_data_source.dart';
// import 'data/data_sources/booking_local_data_source_impl.dart';
// import 'data/data_sources/booking_remote_data_source.dart';
// import 'data/data_sources/booking_remote_data_source_impl.dart';
// import 'data/repositories/booking_repository_impl.dart';
// import 'domain/repositories/i_booking_repository.dart';

// Future<void> initBookingInjection() async {
//   final bookingBox = await Hive.openBox('booking_box');

//   getIt.registerLazySingleton<BookingLocalDataSource>(
//     () => BookingLocalDataSourceImpl(bookingBox),
//   );

//   getIt.registerLazySingleton<BookingRemoteDataSource>(
//     () => BookingRemoteDataSourceImpl(getIt()),
//   );

//   getIt.registerLazySingleton<IBookingRepository>(
//     () => BookingRepositoryImpl(
//       remoteDataSource: getIt(),
//       localDataSource: getIt(),
//       networkInfo: getIt(),
//     ),
//   );

//   // أضف الـ UseCases والـ Cubit هنا لاحقاً بنفس الطريقة
// }

import 'package:get_it/get_it.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_local_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_local_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/data_sources/medical_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/data_sources/medical_remote_data_source_impl.dart';
import 'package:graduation_project/features/booking/data/repositories/medical_repository_impl.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_prescription_items_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/block_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/delete_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_medical_record_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/save_medical_record_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/exam_session_cubit/exam_session_cubit.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_doctor_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'package:hive/hive.dart';
import 'domain/repositories/i_booking_repository.dart';
import 'data/repositories/booking_repository_impl.dart';
import 'domain/use_cases/create_schedule_use_case.dart';
import 'domain/use_cases/generate_slots_use_case.dart';
import 'domain/use_cases/get_active_schedule_use_case.dart';
import 'presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';
// ... باقي الـ Imports (DataSources, NetworkInfo)

// ... Imports ...

final sl = GetIt.instance; // تأكد إنه نفس الـ instance المستخدم في المشروع كله

Future<void> initBookingInjection() async {
  final bookingBox = await Hive.openBox('booking_box');

  // 1. Data Sources
  sl.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(bookingBox),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );

  // ✅ إضافة الـ DataSource الجديد بتاع الميديكال
  sl.registerLazySingleton<MedicalRemoteDataSource>(
    () => MedicalRemoteDataSourceImpl(sl()), // sl هنا هي الـ ApiService
  );

  // 2. Repository
  sl.registerLazySingleton<IBookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ✅ إضافة الـ Repository الجديد بتاع الميديكال
  sl.registerLazySingleton<MedicalRepository>(
    () => MedicalRepositoryImpl(sl()), // sl هنا هي الـ MedicalRemoteDataSource
  );

  // 3. ✅ إضافة الـ UseCases الناقصة (تأكد من الـ imports)
  sl.registerLazySingleton(() => CreateScheduleUseCase(sl()));
  sl.registerLazySingleton(() => GenerateSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveScheduleUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorSlotsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAppointmentStatusUseCase(sl()));

  sl.registerLazySingleton(() => GetMedicalRecordUseCase(sl()));
  sl.registerLazySingleton(() => SaveMedicalRecordUseCase(sl()));
  sl.registerLazySingleton(() => CreatePrescriptionUseCase(sl()));

  // ⬅️ السطر اللي كان ناقص وعامل الإيرور:
  sl.registerLazySingleton(() => CreateManualSlotUseCase(sl()));
  sl.registerLazySingleton(() => BookFollowUpUseCase(sl()));
  // يفضل تضيف دول كمان لو الكيوبت بيستخدمهم:
  sl.registerLazySingleton(() => BlockSlotUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSlotUseCase(sl()));
  sl.registerLazySingleton(() => GetPrescriptionUseCase(sl()));
  sl.registerLazySingleton(() => AddPrescriptionItemsUseCase(sl()));

  // 4. Cubits
  sl.registerFactory(() => ScheduleManagementCubit(sl(), sl(), sl()));
  sl.registerFactory(() => BookingCalendarCubit(sl()));
  sl.registerFactory(() => ExamSessionCubit(sl(), sl(), sl(), sl(), sl()));

  // تأكد إن ترتيب الـ sl() هنا مطابق لترتيب الـ parameters في الـ Constructor بتاع الـ Cubit
  sl.registerFactory(
    () => AppointmentActionCubit(sl(), sl(), sl(), sl(), sl()),
  );
}
