import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
import 'package:graduation_project/features/notification/presentation/pages/notification_tile.dart';

// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({super.key});

//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // تحميل أول صفحة
//     context.read<NotificationCubit>().fetchNotifications();
//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.8) {
//       context.read<NotificationCubit>().fetchMore();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "الإشعارات",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
//             child: const Text(
//               "تحديد الكل كمقروء",
//               style: TextStyle(color: Colors.teal),
//             ),
//           ),
//         ],
//       ),
//       body: BlocBuilder<NotificationCubit, NotificationState>(
//         builder: (context, state) {
//           if (state is NotificationLoading)
//             return const Center(child: CircularProgressIndicator());
//           if (state is NotificationFailure)
//             return Center(child: Text(state.error));

//           final notifications =
//               context.read<NotificationCubit>().allNotifications;

//           if (notifications.isEmpty) {
//             return const Center(child: Text("لا توجد إشعارات حالياً"));
//           }

//           return RefreshIndicator(
//             onRefresh:
//                 () => context.read<NotificationCubit>().fetchNotifications(),
//             child: ListView.separated(
//               controller: _scrollController,
//               itemCount:
//                   notifications.length +
//                   (context.read<NotificationCubit>().hasNextPage ? 1 : 0),
//               separatorBuilder: (_, __) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 if (index == notifications.length) {
//                   return const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return NotificationTile(
//                   notification: notifications[index],
//                   onTap:
//                       () => _handleNotificationClick(
//                         context,
//                         notifications[index],
//                       ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
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
    // 💡 تعديل حساس السكرول
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
          "الإشعارات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: const Text(
              "تحديد الكل كمقروء",
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          // جلب الداتا من الـ Cubit مباشرة لضمان وجودها في كل الحالات (Success/LoadingMore)
          final cubit = context.read<NotificationCubit>();
          final notifications = cubit.allNotifications;

          if (state is NotificationLoading && notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationFailure && notifications.isEmpty) {
            return Center(child: Text(state.error));
          }

          if (notifications.isEmpty) {
            return const Center(child: Text("لا توجد إشعارات حالياً"));
          }

          return RefreshIndicator(
            onRefresh: () => cubit.fetchNotifications(),
            child: ListView.separated(
              controller: _scrollController,
              // بنزود 1 لو فيه صفحة تانية عشان نظهر الـ Loader تحت
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
                    // Navigator.pop(context); // اقفل القائمة الأول
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

  void _handleNotificationClick(BuildContext context, NotificationEntity noti) {
    // 1. تعليم الإشعار كمقروء
    context.read<NotificationCubit>().markAsRead(noti.id);
    final String? entityId = noti.relatedEntityId ?? noti.relatedEntityKey;
    // 2. التوجيه حسب النوع (Deep Linking)
    // if (noti.relatedEntityId == null) return;
    if (entityId == null) {
      debugPrint("⚠️ No ID found in notification payload");
      return;
    }

    switch (noti.relatedEntityType?.toLowerCase()) {
      // case 'ticket':

      //   debugPrint(
      //     "Navigating to ticket: $entityId}",
      //   );
      //   context.push('/tickets/ticket-chat', extra: entityId);
      //   break;
      case 'ticket':
        String? estimatedStatus;

        // 💡 استنتاج ذكي للحالة عشان الـ UI ينور صح فوراً
        if (noti.type == 'TicketClosed') {
          estimatedStatus = 'Closed';
        } else if (noti.type == 'TicketResponse') {
          estimatedStatus = 'InProgress';
        }

        context.push(
          '/tickets/ticket-chat',
          extra: {'id': noti.relatedEntityKey, 'status': estimatedStatus},
        );
        break;
      case 'appointment':
        // التوجيه لتفاصيل الحجز (سواء للدكتور أو المريض)
        context.push('/appointments/details/${noti.relatedEntityId}');
        break;
      case 'prescription':
        // التوجيه لصفحة الروشتة (للمريض)
        context.push('/prescriptions/${noti.relatedEntityId}');
        break;
      case 'medicalrecord':
        // التوجيه للسجل الطبي
        context.push('/medical-records/${noti.relatedEntityId}');
        break;
      default:
        // debugPrint("Unknown entity type: ${noti.relatedEntityType}");
        debugPrint("Unknown target: ${noti.navigationTarget}");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 💡 ضروري جداً لتجنب تسريب الذاكرة
    super.dispose();
  }
}
