import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/services/notification_service.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:app_links/app_links.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationService.onActionReceivedMethod,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
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
    log('📩 Received app link: $uri');
    final String fullPath = uri.toString();
    if (uri.path.contains('reset-password')) {
      final email = uri.queryParameters['email'];
      final token = uri.queryParameters['token'];

      if (email != null && token != null) {
        AppRouter.router.go(
          '${AppRouter.kResetPassword}?email=$email&token=$token',
        );
      }
    }
    if (fullPath.contains('share-history')) {
      String? token = uri.queryParameters['token'];

      if (token == null && uri.fragment.contains('token=')) {
        token = uri.fragment.split('token=').last;
      }

      if (token != null) {
        log('✅ Navigating with token: $token');
        AppRouter.router.push('/share-history?token=$token');
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
