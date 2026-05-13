import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/notification/data/models/notification_model.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationsResultEntity>> getNotifications({
    int page = 1,
    bool unreadOnly = false,
  });
  Future<Either<Failure, String>> markAsRead(String id);
  Future<Either<Failure, String>> markAllAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService apiService;
  NotificationRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, NotificationsResultEntity>> getNotifications({
    int page = 1,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await apiService.get(
        "notifications",
        queryParameters: {
          "page": page,
          "pageSize": 15,
          "unreadOnly": unreadOnly,
        },
      );

      final List<NotificationModel> list =
          (response['notifications'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList();

      return Right(
        NotificationsResultEntity(
          notifications: list,
          unreadCount: response['unreadCount'] ?? 0,
          totalCount: response['totalCount'] ?? 0,
          hasNextPage: response['hasNextPage'] ?? false,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> markAsRead(String id) async {
    try {
      final response = await apiService.post("notifications/$id/mark-as-read");
      return Right(response['message'] ?? "Success");
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> markAllAsRead() async {
    try {
      final response = await apiService.post("notifications/mark-all-as-read");
      return Right(response['message'] ?? "Success");
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
