import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/notification_service.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:app_links/app_links.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // لو عايز تعمل حاجة لما يوصل إشعار والتطبيق مقفول (زي تحديث داتا في الخلفية)
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  final now = DateTime.now(); // وقت وصول الرسالة للموبايل

  print("\n🚨🚨🚨 === BACKGROUND NOTIFICATION RECEIVED === 🚨🚨🚨");
  print("⏰ Actual Receipt Time: $now"); // الوقت الحالي اللي الموبايل استلم فيه
  print("🆔 Message ID: ${message.messageId}");
  print("📌 Title: ${message.notification?.title}");
  print("📝 Body: ${message.notification?.body}");
  print(
    "📦 Data Payload: ${message.data}",
  ); // الداتا المخفية اللي جاية من الباك
  print("🚨🚨🚨 =========================================== 🚨🚨🚨\n");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ✅ 3. ربط دالة الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ 4. طلب الإذن وتشغيل المستمعات
  // await NotificationService.initNotifications();
  setupServiceLocator();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.initNotifications(context); // 👈 استدعاء هنا
    });
    _initDeepLinks();
    // Future.delayed(Duration.zero, () {
    //   NotificationService.initNotifications(context);
    // });
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    });

    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleIncomingLink(initialLink);
    }
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint('📩 Received app link: $uri');

    if (uri.path.contains('reset-password')) {
      final email = uri.queryParameters['email'];
      final token = uri.queryParameters['token'];

      if (email != null && token != null) {
        AppRouter.router.go(
          '${AppRouter.kResetPassword}?email=$email&token=$token',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          title: 'Wellora',
          theme: ThemeData(primarySwatch: Colors.green),
        );
      },
    );
  }
}
