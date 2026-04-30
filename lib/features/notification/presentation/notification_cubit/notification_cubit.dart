import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/features/notification/data/models/notification_model.dart';
import 'package:graduation_project/features/notification/data/repos/notification_repository_impl.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  final SignalRService signalRService;

  NotificationCubit(this.repository, this.signalRService)
    : super(NotificationInitial()) {
    _subscribeToSignalR();
  }

  int unreadCount = 0;
  int currentPage = 1;
  bool hasNextPage = true;
  List<NotificationEntity> allNotifications = [];

  void _subscribeToSignalR() {
    signalRService.on("NotificationReceived", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final newNoti = NotificationModel.fromJson(
            arguments[0] as Map<String, dynamic>,
          );

          if (!allNotifications.any((n) => n.id == newNoti.id)) {
            allNotifications.insert(0, newNoti);
            unreadCount++;
            emit(NotificationSuccess(List.from(allNotifications)));
          }
        } catch (e) {
          log("❌ SignalR Notification Error: $e");
        }
      }
    });
  }

  Future<void> fetchNotifications({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      emit(NotificationLoading());
    }

    final result = await repository.getNotifications(page: currentPage);

    result.fold((f) => emit(NotificationFailure(f.errmessage)), (data) {
      if (isRefresh) {
        allNotifications = data.notifications;
        unreadCount = data.unreadCount;
      } else {
        final newNotifications =
            data.notifications
                .where(
                  (newNoti) =>
                      !allNotifications.any(
                        (oldNoti) => oldNoti.id == newNoti.id,
                      ),
                )
                .toList();

        allNotifications.addAll(newNotifications);
      }

      hasNextPage = data.hasNextPage;
      currentPage++;

      emit(NotificationSuccess(List.from(allNotifications)));
    });
  }

  Future<void> fetchMore() async {
    if (!hasNextPage || state is NotificationLoadingMore) return;

    emit(NotificationLoadingMore(List.from(allNotifications)));
    await fetchNotifications(isRefresh: false);
  }

  Future<void> markAsRead(String id) async {
    final index = allNotifications.indexWhere((n) => n.id == id);
    if (index != -1 && !allNotifications[index].isRead) {
      final updatedNoti = NotificationModel(
        id: allNotifications[index].id,
        title: allNotifications[index].title,
        message: allNotifications[index].message,
        type: allNotifications[index].type,
        isRead: true, // حدثنا الحالة
        createdAt: allNotifications[index].createdAt,
        relatedEntityId: allNotifications[index].relatedEntityId,
        relatedEntityType: allNotifications[index].relatedEntityType,
      );

      allNotifications[index] = updatedNoti;
      if (unreadCount > 0) unreadCount--;
      emit(NotificationSuccess(List.from(allNotifications)));
    }

    await repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    allNotifications =
        allNotifications.map((n) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            relatedEntityId: n.relatedEntityId,
            relatedEntityType: n.relatedEntityType,
          );
        }).toList();

    unreadCount = 0;
    emit(NotificationSuccess(List.from(allNotifications)));
    await repository.markAllAsRead();
  }
}
