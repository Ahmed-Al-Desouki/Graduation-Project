import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/data/models/appointment_full_details_model.dart';
import 'package:graduation_project/features/booking/data/models/schedule_model.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/day_slots_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/i_booking_repository.dart';
import '../data_sources/booking_local_data_source.dart';
import '../data_sources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final BookingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createSchedule(
    ScheduleEntity
    schedule, // يفضل مستقبلاً تغيير الـ Entity لـ DayConfigEntity
  ) async {
    return await _handleRemoteRequest(() async {
      // 🚨 التعديل الأهم: بناء الـ Body بناءً على الدوكيومنت الجديد صفحة 3
      // بما إن الـ Entity القديمة فيها timeRanges (قائمة)،
      // والباك الجديد بياخد يوم بيوم، هناخد أول عنصر كمثال أو نعدل الـ Entity

      final firstRange = schedule.timeRanges.first;

      final body = {
        "dayOfWeek": firstRange.dayOfWeek, // الرقم من 0 لـ 6
        "startTime": firstRange.startTime,
        "endTime": firstRange.endTime,
        "slotDurationMinutes": schedule.slotDurationMinutes,
        "bufferTimeMinutes": schedule.bufferTimeMinutes,
      };

      final doctorId = getIt<SessionManager>().userId;

      // نداء الـ Remote المحدث اللي بيعمل PUT
      return await remoteDataSource.createSchedule(doctorId, body);
    });
  }

  @override
  Future<Either<Failure, void>> generateSlots(
    String doctorId,
    DateTime start,
    DateTime end,
    bool regenerate,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.generateSlots(doctorId, {
        "startDate": start.toIso8601String(),
        "endDate": end.toIso8601String(),
        "regenerateExisting": regenerate,
      });
    });
  }

  // --- 2. إدارة المواعيد والـ Slots ---

  @override
  Future<Either<Failure, List<DaySlotsEntity>>> getSlotsRange(
    String doctorId,
    DateTime start,
    DateTime end, {
    String? status,
  }) async {
    // if (await networkInfo.isConnected) {
    try {
      final remoteData = await remoteDataSource.getSlotsRange(
        doctorId,
        start.toIso8601String(),
        end.toIso8601String(),
        status: status,
      );
      await localDataSource.cacheDaySlots(remoteData);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
    // } else {
    //   try {
    //     final localData = await localDataSource.getCachedDaySlots();
    //     return Right(localData);
    //   } catch (e) {
    //     return Left(CacheFailure("لا توجد بيانات مخزنة لهذا النطاق"));
    //   }
    // }
  }

  @override
  Future<Either<Failure, List<AppointmentFullDetailsEntity>>>
  getDoctorAppointments(DateTime date, String status) async {
    return await _handleRemoteRequest(() async {
      final response = await remoteDataSource.getDoctorAppointments(
        date.toIso8601String(),
        status,
      );
      // تحويل الـ JSON لموديلات ثم لـ Entities
      return response
          .map((json) => AppointmentFullDetailsModel.fromJson(json))
          .toList();
    });
  }

  // --- 3. الاستثناءات وساعات العمل الخاصة ---

  @override
  Future<Either<Failure, void>> addDayOff(
    String doctorId,
    DateTime date,
    String reason,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.addDayOff(doctorId, {
        "date": date.toIso8601String(),
        "reason": reason,
      });
    });
  }

  @override
  Future<Either<Failure, void>> addCustomHours(
    String doctorId,
    DateTime date,
    String start,
    String end,
    String reason,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.addCustomHours(doctorId, {
        "date": date.toIso8601String(),
        "startTime": start,
        "endTime": end,
        "reason": reason,
      });
    });
  }

  @override
  Future<Either<Failure, void>> removeException(
    String doctorId,
    DateTime date,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.removeException(doctorId, date.toIso8601String());
    });
  }

  // --- 4. التحكم في الحجوزات (Actions) ---

  @override
  Future<Either<Failure, void>> confirmAppointment(String id) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.updateAppointmentStatus(id, 'confirm'),
    );
  }

  @override
  Future<Either<Failure, void>> startAppointment(String id) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.updateAppointmentStatus(id, 'start'),
    );
  }

  @override
  Future<Either<Failure, void>> completeAppointment(String id) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.updateAppointmentStatus(id, 'complete'),
    );
  }

  // @override
  // Future<Either<Failure, void>> cancelAppointment(
  //   String id,
  //   String reason,
  // ) async {
  //   return await _handleRemoteRequest(
  //     () => remoteDataSource.updateAppointmentStatus(
  //       id,
  //       'cancel',
  //       body: {"reason": reason},
  //     ),
  //   );
  // }

  @override
  Future<Either<Failure, void>> blockSlot(
    String doctorId,
    String slotId,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.blockSlot(doctorId, slotId),
    );
  }

  @override
  Future<Either<Failure, void>> deleteSlot(
    String doctorId,
    String slotId,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.deleteSlot(doctorId, slotId),
    );
  }

  @override
  Future<Either<Failure, void>> createManualSlot(
    String doctorId,
    DateTime date,
    String start,
    String end,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.createManualSlot(doctorId, {
        "slotDate": date.toIso8601String(),
        "startTime": start,
        "endTime": end,
      });
    });
  }

  @override
  Future<Either<Failure, void>> cancelAppointmentByDoctor(
    String id,
    String reason,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.cancelByDoctor(id, {"reason": reason}),
    );
  }

  @override
  Future<Either<Failure, void>> cancelAppointmentByPatient(
    String id,
    String reason,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.cancelByPatient(id, {"reason": reason}),
    );
  }
  // --- 5. المتابعة (Follow-up) ---

  @override
  Future<Either<Failure, void>> bookFollowUpExisting(
    String originalId,
    String slotId,
    String notes,
    String instructions,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.bookFollowUp(originalId, 'existing', {
        "slotId": slotId,
        "patientNotes": notes,
        "followUpInstructions": instructions,
      });
    });
  }

  @override
  Future<Either<Failure, void>> bookFollowUpNew(
    String originalId,
    DateTime date,
    String start,
    int duration,
    String notes,
    String instructions,
  ) async {
    return await _handleRemoteRequest(() async {
      await remoteDataSource.bookFollowUp(originalId, 'new', {
        "followUpDate": date.toIso8601String(),
        "startTime": start,
        "durationMinutes": duration,
        "patientNotes": notes,
        "followUpInstructions": instructions,
      });
    });
  }

  // --- Helper Method ---
  Future<Either<Failure, T>> _handleRemoteRequest<T>(
    Future<T> Function() action,
  ) async {
    // if (await networkInfo.isConnected) {
    try {
      final result = await action();
      return Right(result);
    } catch (e) {
      // 💡 هنا التعديل السحري
      if (e is DioException) {
        // بنحاول نسحب الرسالة اللي جوه الـ JSON اللي السيرفر بعته
        final serverMessage =
            e.response?.data?['error'] ?? "Something went wrong";
        return Left(ServerFailure(serverMessage));
      }
      return Left(ServerFailure(e.toString()));
    }
    // } else {
    //   return Left(OfflineFailure("لا يوجد اتصال بالإنترنت حالياً"));
    // }
  }

  // @override
  // Future<Either<Failure, ScheduleEntity>> getActiveSchedule(
  //   String doctorId,
  // ) async {
  //   // if (await networkInfo.isConnected) {
  //   try {
  //     final remoteData = await remoteDataSource.getActiveSchedule(doctorId);

  //     // حفظ في الكاش المحلي (Hive)
  //     await localDataSource.cacheActiveSchedule(remoteData);

  //     // تحويل الـ JSON لـ Entity (بافتراض وجود MapToEntity mapper)
  //     return Right(ScheduleModel.fromJson(remoteData));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  //   // } else {
  //   //   try {
  //   //     final localData = await localDataSource.getCachedActiveSchedule();
  //   //     return Right(ScheduleModel.fromJson(localData));
  //   //   } catch (e) {
  //   //     return Left(CacheFailure("لا يوجد جدول مخزن حالياً"));
  //   //   }
  //   // }
  // }

  @override
  Future<Either<Failure, ScheduleEntity>> getActiveSchedule(
    String doctorId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getActiveSchedule(doctorId);

      // حفظ في الكاش المحلي
      await localDataSource.cacheActiveSchedule(remoteData);

      // تحويل الـ JSON (الذي أصبح قائمة أيام في v2.0) لـ Entity
      // تأكد أن ScheduleModel.fromJson مهيأ لاستقبال الشكل الجديد
      return Right(ScheduleModel.fromV2List(remoteData));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // داخل BookingRepositoryImpl
  @override
  Future<Either<Failure, String>> createAppointment(
    BookingEntity booking,
  ) async {
    return await _handleRemoteRequest(() async {
      return await remoteDataSource.createAppointment({
        "timeSlotId": booking.timeSlotId, // ✅ الاسم الصحيح
        "patientNotes": booking.patientNotes,
        "grantMedicalHistoryAccess": booking.grantMedicalHistoryAccess, // ✅
      });
    });
  }

  @override
  Future<Either<Failure, void>> removeWorkingDay(
    String doctorId,
    int dayOfWeek,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.removeWorkingDay(doctorId, dayOfWeek),
    );
  }

  // داخل class BookingRepositoryImpl

  @override
  Future<Either<Failure, AppointmentFullDetailsEntity>>
  getAppointmentFullDetails(String appointmentId) async {
    return await _handleRemoteRequest(() async {
      // 1. طلب البيانات الخام (JSON) من الـ Remote Data Source
      final response = await remoteDataSource.getAppointmentFullDetails(
        appointmentId,
      );

      // 2. تحويل الـ JSON لموديل (الذي يرث من الـ Entity)
      // ملاحظة: تأكد إنك عملت ملف الموديل اللي اتفقنا عليه في الرد السابق
      return AppointmentFullDetailsModel.fromJson(response);
    });
  }
}
