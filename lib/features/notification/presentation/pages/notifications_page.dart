import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/notification/domain/entities/notification_entity.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
import 'package:graduation_project/features/notification/presentation/pages/notification_tile.dart';

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

  void _handleNotificationClick(BuildContext context, NotificationEntity noti) {
    context.read<NotificationCubit>().markAsRead(noti.id);
    final String? entityId = noti.relatedEntityId ?? noti.relatedEntityKey;

    if (entityId == null) {
      log("⚠️ No ID found in notification payload");
      return;
    }

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
          extra: {'id': noti.relatedEntityKey, 'status': estimatedStatus},
        );
        break;
      case 'appointment':
        context.push('/appointments/details/${noti.relatedEntityId}');
        break;
      case 'prescription':
        context.push('/prescriptions/${noti.relatedEntityId}');
        break;
      case 'medicalrecord':
        context.push('/medical-records/${noti.relatedEntityId}');
        break;
      default:
        log("Unknown target: ${noti.navigationTarget}");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
