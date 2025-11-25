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
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  }) async {
    try {
      final res = await _webService.createReminder(
        patientId,
        type: type,
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
  Future<Either<Failure, ReminderInstanceModel>> getUpcomingReminders({
    required String patientId,
    required int hours,
  }) async {
    try {
      final res = await _webService.getUpcomingReminders(patientId);
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
}
