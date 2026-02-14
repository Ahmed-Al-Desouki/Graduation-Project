import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/data/models/appointment_model.dart';
import 'package:graduation_project/features/booking/data/models/schedule_model.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_entity.dart';
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

  // --- 1. إدارة الجداول (Schedules) ---

  @override
  Future<Either<Failure, String>> createSchedule(
    ScheduleEntity schedule,
  ) async {
    return await _handleRemoteRequest(() async {
      final body = {
        "templateName": schedule.templateName,
        "slotDurationMinutes": schedule.slotDurationMinutes,
        "bufferTimeMinutes": schedule.bufferTimeMinutes,
        "effectiveFromDate": schedule.effectiveFromDate.toIso8601String(),
        "effectiveToDate": schedule.effectiveToDate.toIso8601String(),
        "timeRanges":
            schedule.timeRanges
                .map(
                  (e) => {
                    "dayOfWeek": e.dayOfWeek,
                    "startTime": e.startTime,
                    "endTime": e.endTime,
                  },
                )
                .toList(),
      };
      final doctorId = getIt<SessionManager>().userId;
      // ✅ ضيف الـ print ده عشان تشوف الـ ID في الـ Terminal قبل ما يبعت
      print("DEBUG: Doctor ID from SessionManager is: '$doctorId'");

      // if (doctorId.isEmpty) {
      //   return Left(ServerFailure("Doctor ID is empty. Please re-login."));
      // }
      // 2. هنبعت الـ ID النصي الجاهز للـ Remote Data Source
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
  Future<Either<Failure, List<AppointmentEntity>>> getDoctorAppointments(
    DateTime date,
    String status,
  ) async {
    return await _handleRemoteRequest(() async {
      final response = await remoteDataSource.getDoctorAppointments(
        date.toIso8601String(),
        status,
      );
      // تحويل الـ JSON لموديلات ثم لـ Entities
      return response.map((json) => AppointmentModel.fromJson(json)).toList();
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

  @override
  Future<Either<Failure, void>> cancelAppointment(
    String id,
    String reason,
  ) async {
    return await _handleRemoteRequest(
      () => remoteDataSource.updateAppointmentStatus(
        id,
        'cancel',
        body: {"reason": reason},
      ),
    );
  }

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
      return Left(ServerFailure(e.toString()));
    }
    // } else {
    //   return Left(OfflineFailure("لا يوجد اتصال بالإنترنت حالياً"));
    // }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> getActiveSchedule(
    String doctorId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getActiveSchedule(doctorId);

        // حفظ في الكاش المحلي (Hive)
        await localDataSource.cacheActiveSchedule(remoteData);

        // تحويل الـ JSON لـ Entity (بافتراض وجود MapToEntity mapper)
        return Right(ScheduleModel.fromJson(remoteData));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localData = await localDataSource.getCachedActiveSchedule();
        return Right(ScheduleModel.fromJson(localData));
      } catch (e) {
        return Left(CacheFailure("لا يوجد جدول مخزن حالياً"));
      }
    }
  }
}
