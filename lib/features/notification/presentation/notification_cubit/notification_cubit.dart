// import 'package:admin_dashboard_graduation_project/core/services/signalr_service.dart';
// import 'package:admin_dashboard_graduation_project/features/dashboard/domain/entities/notification_entity.dart';
// import 'package:admin_dashboard_graduation_project/features/dashboard/domain/models/notification_model.dart';
// import 'package:admin_dashboard_graduation_project/features/dashboard/domain/repositories/notification_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
    // الاستماع لحدث NotificationReceived كما هو مذكور في الـ Guide
    signalRService.on("NotificationReceived", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final newNoti = NotificationModel.fromJson(
            arguments[0] as Map<String, dynamic>,
          );

          // 🚀 التزاماً بالـ Guide: Deduplicate by ID
          if (!allNotifications.any((n) => n.id == newNoti.id)) {
            allNotifications.insert(0, newNoti); // إضافة الجديد في البداية
            unreadCount++;
            emit(NotificationSuccess(List.from(allNotifications)));
          }
        } catch (e) {
          debugPrint("❌ SignalR Notification Error: $e");
        }
      }
    });
  }

  // Future<void> fetchNotifications({bool isRefresh = true}) async {
  //   if (isRefresh) {
  //     currentPage = 1;
  //     emit(NotificationLoading());
  //   }

  //   final result = await repository.getNotifications(page: currentPage);

  //   result.fold((f) => emit(NotificationFailure(f.errmessage)), (data) {
  //     if (isRefresh) {
  //       allNotifications = data.notifications;
  //     } else {
  //       allNotifications.addAll(data.notifications);
  //     }

  //     unreadCount = data.unreadCount;
  //     hasNextPage = data.hasNextPage;
  //     currentPage++;

  //     emit(NotificationSuccess(List.from(allNotifications)));
  //   });
  // }
  Future<void> fetchNotifications({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      emit(NotificationLoading());
    }

    final result = await repository.getNotifications(page: currentPage);

    result.fold((f) => emit(NotificationFailure(f.errmessage)), (data) {
      if (isRefresh) {
        allNotifications = data.notifications;
        // في أول تحميلة بس بنثق في عداد السيرفر
        unreadCount = data.unreadCount;
      } else {
        // 🚀 التزاماً بالـ Guide: منع التكرار عند الباجنيشن
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
        // 💡 في الباجنيشن مش بنحدث الـ unreadCount من السيرفر عشان محصلش Stale
      }

      hasNextPage = data.hasNextPage;
      // hasNextPage = data.notifications.length == 15;
      currentPage++;

      emit(NotificationSuccess(List.from(allNotifications)));
    });
  }

  // ميثود التحميل الإضافي (Pagination)
  Future<void> fetchMore() async {
    if (!hasNextPage || state is NotificationLoadingMore) return;

    emit(NotificationLoadingMore(List.from(allNotifications)));
    await fetchNotifications(isRefresh: false);
  }

  // Future<void> markAsRead(String id) async {
  //   // تحديث فوري (Optimistic Update) لتحسين الـ UX
  //   final index = allNotifications.indexWhere((n) => n.id == id);
  //   if (index != -1 && !allNotifications[index].isRead) {
  //     final updatedNoti = NotificationEntity(
  //       id: allNotifications[index].id,
  //       title: allNotifications[index].title,
  //       message: allNotifications[index].message,
  //       type: allNotifications[index].type,
  //       isRead: true,
  //       createdAt: allNotifications[index].createdAt,
  //       relatedEntityId: allNotifications[index].relatedEntityId,
  //       relatedEntityType: allNotifications[index].relatedEntityType,
  //     );

  //     allNotifications[index] = updatedNoti;
  //     if (unreadCount > 0) unreadCount--;
  //     emit(NotificationSuccess(List.from(allNotifications)));
  //   }

  //   await repository.markAsRead(id);
  // }

  Future<void> markAsRead(String id) async {
    final index = allNotifications.indexWhere((n) => n.id == id);
    if (index != -1 && !allNotifications[index].isRead) {
      // 🚀 التعديل هنا: نستخدم NotificationModel بدل NotificationEntity
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

      allNotifications[index] = updatedNoti; // كدة النوع هيركب صح
      if (unreadCount > 0) unreadCount--;
      emit(NotificationSuccess(List.from(allNotifications)));
    }

    await repository.markAsRead(id);
  }

  // Future<void> markAllAsRead() async {
  //   allNotifications =
  //       allNotifications.map((n) {
  //         return NotificationEntity(
  //           id: n.id,
  //           title: n.title,
  //           message: n.message,
  //           type: n.type,
  //           isRead: true,
  //           createdAt: n.createdAt,
  //           relatedEntityId: n.relatedEntityId,
  //           relatedEntityType: n.relatedEntityType,
  //         );
  //       }).toList();

  //   unreadCount = 0;
  //   emit(NotificationSuccess(List.from(allNotifications)));
  //   await repository.markAllAsRead();
  // }
  Future<void> markAllAsRead() async {
    allNotifications =
        allNotifications.map((n) {
          // 🚀 برضه نستخدم NotificationModel هنا
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
