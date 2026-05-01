import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
import 'package:graduation_project/features/notification/presentation/pages/notification_tile.dart';
import 'package:graduation_project/features/review/presentation/review_cubit/review_cubit.dart';
import 'package:graduation_project/features/review/presentation/widgets/doctor_review_sheet.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: const Text(
              "Mark All as Read",
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final cubit = context.read<NotificationCubit>();
          final notifications = cubit.allNotifications;

          if (state is NotificationLoading && notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationFailure && notifications.isEmpty) {
            return Center(child: Text(state.error));
          }

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          return RefreshIndicator(
            onRefresh: () => cubit.fetchNotifications(),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: notifications.length + (cubit.hasNextPage ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return NotificationTile(
                  notification: notifications[index],
                  onTap: () {
                    _handleNotificationClick(context, notifications[index]);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // void _handleNotificationClick(BuildContext context, NotificationEntity noti) {
  //   context.read<NotificationCubit>().markAsRead(noti.id);
  //   final String? entityId = noti.relatedEntityId ?? noti.relatedEntityKey;

  //   if (entityId == null) {
  //     log("⚠️ No ID found in notification payload");
  //     return;
  //   }

  //   switch (noti.relatedEntityType?.toLowerCase()) {
  //     case 'ticket':
  //       String? estimatedStatus;

  //       if (noti.type == 'TicketClosed') {
  //         estimatedStatus = 'Closed';
  //       } else if (noti.type == 'TicketResponse') {
  //         estimatedStatus = 'InProgress';
  //       }

  //       context.push(
  //         '/tickets/ticket-chat',
  //         extra: {'id': noti.relatedEntityKey, 'status': estimatedStatus},
  //       );
  //       break;
  //     case 'appointment':
  //       context.push('/appointments/details/${noti.relatedEntityId}');
  //       break;
  //     case 'prescription':
  //       context.push('/prescriptions/${noti.relatedEntityId}');
  //       break;
  //     case 'medicalrecord':
  //       context.push('/medical-records/${noti.relatedEntityId}');
  //       break;
  //     default:
  //       log("Unknown target: ${noti.navigationTarget}");
  //   }
  // }

  void _handleNotificationClick(BuildContext context, NotificationEntity noti) {
    context.read<NotificationCubit>().markAsRead(noti.id);

    // 1. استخراج الـ ID الصحيح (بنشيك على الـ Key والـ Id)
    final String? entityId = noti.relatedEntityKey ?? noti.relatedEntityId;

    // 2. 🚀 الحل السحري: بنشيك على نوع التنبيه لو "طلب تقييم"
    // بنبص على الـ type أو الـ navigationTarget
    if (noti.type == 'ReviewRequested' ||
        noti.navigationTarget == 'review_create') {
      // بنجيب الـ doctorId من الـ payload اللي جاي مع التنبيه
      // تأكد إن الـ NotificationEntity عندك فيها حقل للـ payload أو الـ metadata
      final doctorId = noti.navigationPayload?['doctorId'];

      if (doctorId != null) {
        _showReviewSheet(context, int.tryParse(doctorId.toString()) ?? 0);
        return; // بنوقف هنا مش عاوزينه يكمل للـ switch
      }
    }

    if (entityId == null) {
      log("⚠️ No ID found in notification payload");
      return;
    }

    // 3. تصليح المسارات باستخدام AppRouter (بلاش كتابة الـ Path يدوي)
    switch (noti.relatedEntityType?.toLowerCase()) {
      case 'ticket':
        String? estimatedStatus;
        if (noti.type == 'TicketClosed') {
          estimatedStatus = 'Closed';
        } else if (noti.type == 'TicketResponse') {
          estimatedStatus = 'InProgress';
        }
        context.push(
          '/tickets/ticket-chat',
          extra: {'id': entityId, 'status': estimatedStatus},
        );
        break;

      case 'appointment':
      case 'prescription':
        // ✅ تصليح: استخدم الـ Constant والـ extra بدل الـ Path اليدوي
        context.push(
          AppRouter.kMedicalDetails,
          extra: {'appointmentId': entityId, 'isReadOnly': true},
        );
        break;

      // لو عندك شاشة أدوية، استخدم الـ Route بتاعها
      // context.push('/prescriptions/$entityId');
      // break;

      default:
        log("Unknown target: ${noti.navigationTarget}");
    }
  }

  // ميثود مساعدة لفتح الشيت
  void _showReviewSheet(BuildContext context, int doctorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider(
            create: (context) => getIt<ReviewCubit>(),
            child: DoctorReviewSheet(doctorId: doctorId),
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
