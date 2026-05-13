import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
import 'package:graduation_project/features/reminder/data/data_sources/local_occurrence_data_source.dart';
import 'package:graduation_project/features/review/presentation/review_cubit/review_cubit.dart';
import 'package:graduation_project/features/review/presentation/widgets/doctor_review_sheet.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'medication_channel',
        channelName: 'Medication Alarms',
        channelDescription: 'Channel for high-priority medication reminders',
        defaultColor: const Color(0xFF2563EB),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        locked: true,
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        soundSource: 'resource://raw/alarm_sound',
      ),

      NotificationChannel(
        channelKey: 'general_channel',
        channelName: 'General Notifications',
        importance: NotificationImportance.Max,
        channelDescription: 'Notifications for tickets, appointments, and chat',
        defaultColor: const Color(0xFF2563EB),
        ledColor: Colors.white,
        channelShowBadge: true,
        playSound: true,
        criticalAlerts: true,
      ),
    ]);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String type,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'medication_channel',
        title: title,
        body: body,
        category: NotificationCategory.Alarm,
        notificationLayout: NotificationLayout.Default,
        fullScreenIntent: true,
        wakeUpScreen: true,
        payload: {'id': id.toString(), 'type': type},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'TAKEN',
          label: 'Mark as Taken',
          color: Colors.green,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Snooze',
          color: Colors.orange,
          actionType: ActionType.KeepOnTop,
        ),
      ],
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
    log("⏰ Alarm Scheduled at: $scheduledDate");
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.channelKey == 'general_channel') {
      _handleNotificationNavigation(receivedAction.payload ?? {});
      return;
    }

    if (receivedAction.channelKey == 'medication_channel') {
      final int? occurrenceId = int.tryParse(
        receivedAction.payload?['id'] ?? '',
      );
      final String actionKey = receivedAction.buttonKeyPressed;

      if (actionKey.isEmpty) {
        AppRouter.router.push(
          AppRouter.kRinging,
          extra: receivedAction.payload,
        );
      }

      if (actionKey == 'TAKEN' && occurrenceId != null) {
        await LocalOccurrenceDataSource().updateOccurrenceActionOffline(
          id: occurrenceId,
          newStatus: 2,
        );
        await AwesomeNotifications().dismiss(receivedAction.id!);
        log("Action Recorded: TAKEN for ID: $occurrenceId");
      } else if (actionKey == 'SNOOZE' && occurrenceId != null) {
        await LocalOccurrenceDataSource().updateOccurrenceActionOffline(
          id: occurrenceId,
          newStatus: 4,
        );
      }
    }
  }

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    log("🧭 Handling Navigation with payload: $data");

    final String? navTarget = data['navigationTarget']?.toString();
    final String? notiType = data['type']?.toString();

    if (navTarget == 'review_create' || notiType == 'ReviewRequested') {
      String? doctorIdStr = data['doctorId']?.toString();

      if (doctorIdStr == null && data['navigationPayload'] != null) {
        final match = RegExp(
          r'doctorId:\s*(\d+)',
        ).firstMatch(data['navigationPayload'].toString());
        doctorIdStr = match?.group(1);
      }

      if (doctorIdStr != null) {
        log("🌟 Review Requested for Doctor ID: $doctorIdStr");
        _showReviewDialog(int.parse(doctorIdStr));
        return;
      }
    }

    final String? type = data['relatedEntityType']?.toString().toLowerCase();
    final String? entityId =
        data['relatedEntityKey']?.toString() ??
        data['relatedEntityId']?.toString();

    if (type == 'ticket') {
      AppRouter.router.push('/tickets/ticket-chat', extra: entityId);
    } else if (type == 'appointment') {
      AppRouter.router.push(
        AppRouter.kMedicalDetails,
        extra: {'appointmentId': entityId, 'isReadOnly': true},
      );
    }
  }

  static void _showReviewDialog(int doctorId) {
    final context = AppRouter.navigatorKey.currentContext;

    if (context != null) {
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
  }

  static Future<void> initFirebaseMessaging() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🚨 SERVER DATA RECEIVED: ${message.data}");
      log("🚨 NOTIFICATION OBJECT: ${message.notification?.title}");

      String title =
          message.notification?.title ??
          message.data['title'] ??
          message.data['Title'] ??
          "Wellora Update";

      String body =
          message.notification?.body ??
          message.data['message'] ??
          message.data['Message'] ??
          message.data['body'] ??
          "";

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecond,
          channelKey: 'general_channel',
          title: title,
          body: body,
          payload: message.data.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
          notificationLayout: NotificationLayout.Default,
        ),
      );

      getIt<NotificationCubit>().fetchNotifications();
    });
  }
}
