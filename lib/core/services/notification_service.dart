import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/reminder/data/data_sources/local_occurrence_data_source.dart';

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
    print("⏰ Alarm Scheduled at: $scheduledDate");
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final int occurrenceId = int.parse(receivedAction.payload!['id']!);
    final String actionKey = receivedAction.buttonKeyPressed;

    if (actionKey.isEmpty) {
      AppRouter.router.push(AppRouter.kRinging, extra: receivedAction.payload);
    }

    if (actionKey == 'TAKEN') {
      await LocalOccurrenceDataSource().updateOccurrenceActionOffline(
        id: occurrenceId,
        newStatus: 2,
      );
      await AwesomeNotifications().dismiss(receivedAction.id!);
      print("Action Recorded: TAKEN for ID: $occurrenceId");
    } else if (actionKey == 'SNOOZE') {
      await LocalOccurrenceDataSource().updateOccurrenceActionOffline(
        id: occurrenceId,
        newStatus: 4,
      );
      print("Action Recorded: SNOOZE for ID: $occurrenceId");
    }
  }
}
