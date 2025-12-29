// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;

//   // ✅ عدلنا الدالة عشان تاخد context
//   static Future<void> initNotifications(BuildContext context) async {
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('🔔 User granted permission');

//       // نشغل المستمعات
//       _initForegroundMessages(context);
//       _setupInteractMessage(context);
//     }
//   }

//   // ✅ هنا التعديل: إظهار SnackBar لما التطبيق يكون مفتوح
//   static void _initForegroundMessages(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('🔔 Foreground Message: ${message.notification?.title}');
//       final now = DateTime.now();

//       print("\n🔔🔔🔔 === FOREGROUND NOTIFICATION RECEIVED === 🔔🔔🔔");
//       print("⏰ Actual Receipt Time: $now");
//       print("📌 Title: ${message.notification?.title}");
//       print("📝 Body: ${message.notification?.body}");
//       print("📦 Data Payload: ${message.data}");
//       print("🔔🔔🔔 =========================================== 🔔🔔🔔\n");

//       if (message.notification != null) {
//         // إظهار رسالة لليوزر من تحت
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message.notification!.title ?? 'New Notification',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 if (message.notification!.body != null)
//                   Text(message.notification!.body!),
//               ],
//             ),
//             backgroundColor: Colors.blue.shade900,
//             behavior: SnackBarBehavior.floating,
//             duration: const Duration(seconds: 4),
//             action: SnackBarAction(
//               label: 'View',
//               textColor: Colors.white,
//               onPressed: () {
//                 // لو عايز لما يدوس على الـ SnackBar يروح مكان معين
//                 _handleMessage(message, context);
//               },
//             ),
//           ),
//         );
//       }
//     });
//   }

//   static Future<void> _setupInteractMessage(BuildContext context) async {
//     // لو التطبيق كان مقفول واتفتح من الإشعار
//     RemoteMessage? initialMessage =
//         await _firebaseMessaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleMessage(initialMessage, context);
//     }

//     // لو التطبيق كان في الخلفية
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleMessage(message, context);
//     });
//   }

//   static void _handleMessage(RemoteMessage message, BuildContext context) {
//     // التوجيه للصفحات
//     print("User tapped on notification: ${message.data}");
//     // مثال:
//     // if (message.data['type'] == 'chat') {
//     //   context.push('/chat');
//     // }
//   }
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart'; // تأكد من المسار
import 'package:graduation_project/core/utils/helper/api.dart'; // تأكد من المسار

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initNotifications(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 User granted permission');

      _initForegroundMessages(context);
      _setupInteractMessage(context);
    }
  }

  static void _initForegroundMessages(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground Message: ${message.notification?.title}');
      final now = DateTime.now();

      print("\n🔔🔔🔔 === FOREGROUND NOTIFICATION RECEIVED === 🔔🔔🔔");
      print("⏰ Actual Receipt Time: $now");
      print("📌 Title: ${message.notification?.title}");
      print("📝 Body: ${message.notification?.body}");
      print("📦 Data Payload: ${message.data}");
      print("🔔🔔🔔 =========================================== 🔔🔔🔔\n");
      // 1. عرض الـ SnackBar
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.notification!.title ?? "New Notification",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (message.notification!.body != null)
                  Text(
                    message.notification!.body!,
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                _handleMessage(message, context);
              },
            ),
          ),
        );
      }

      // 2. إرسال التأكيد للسيرفر (باستخدام ApiService)
      // الداتا اللي جاية في الـ Payload (تأكد من الاسم مع الباك اند)
      // في المثال اللي فات كان اسمها 'OccurrenceId' وفي الباك اند ساعات بتبقى 'id'
      final occurrenceId = message.data['OccurrenceId'] ?? message.data['id'];

      if (occurrenceId != null) {
        _markAsSentOnServer(occurrenceId.toString());
      }
    });
  }

  // ✅ التعديل هنا: استخدام ApiService بدلاً من http
  static Future<void> _markAsSentOnServer(String occurrenceId) async {
    try {
      String uid = await SecureStorageHelper.getUserId() ?? "";

      // بننادي الـ ApiService من الـ Service Locator
      await getIt<ApiService>().post(
        'v2/patients/$uid/reminders/mark-sent', // ⚠️ تأكد من الـ Endpoint الصحيح من الباك إند
        {"occurrenceId": int.tryParse(occurrenceId) ?? occurrenceId},
      );
      print("✅ Notification acknowledged on server: $occurrenceId");
    } catch (e) {
      // مش محتاجين نعمل حاجة لو فشل، دي عملية خلفية
      print("⚠️ Acknowledgment failed: $e");
    }
  }

  static Future<void> _setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage, context);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, context);
    });
  }

  static void _handleMessage(RemoteMessage message, BuildContext context) {
    print("User tapped on notification: ${message.data}");
    // التوجيه هنا حسب الحاجة
  }
}
