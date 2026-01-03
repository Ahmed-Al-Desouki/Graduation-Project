import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo.dart';
import 'package:graduation_project/features/reminder/data/services/reminder_web_service.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderWebService _webService;

  ReminderRepositoryImpl(this._webService);

  @override
  Future<Either<Failure, ReminderModel>> createReminder({
    required String patientId,
    required String type,
    required String title,
    required DateTime startDate,    // ← بقى DateTime
  required DateTime? endDate,
    String? rrule,
  SimpleModel? simple,
    required String message,
  }) async {
    try {
      final res = await _webService.createReminder(
        patientId,
        type: type,
        title: title,
        startDate: startDate,    // DateTime
  endDate: endDate,
        rrule: rrule,
        simple: simple,
        message: message,
      );

      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // @override
  // Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
  //   required String patientId,
  //   required int hours,
  // }) async {
  //   try {
  //     final res = await _webService.getUpcomingReminders(patientId);
  //     return Right(res);
  //   } on DioException catch (e) {
  //     return Left(ServerFailure.fromDioException(e));
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, List<ReminderInstanceModel>>> getTodayReminders({
    required String patientId,
  }) async {
    try {
      final res = await _webService.getTodayReminders(patientId);
      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReminderModel>> updateReminder({
    required String patientId,
    required String reminderId,
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  }) async {
    try {
      final res = await _webService.updateReminder(
        patientId,
        reminderId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        intervalHours: intervalHours,
        baseTime: baseTime,
        message: message,
      );

      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder({
    required String patientId,
    required String reminderId,
  }) async {
    try {
      await _webService.deleteReminder(
        patientId: patientId,
        reminderId: reminderId,
      );
      // إذا نجحت الدالة، نرجع Right(null)
      return Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
