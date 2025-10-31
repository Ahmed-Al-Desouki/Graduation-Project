// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   setupServiceLocator();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: AppRouter.router,
//       debugShowCheckedModeBanner: false,
//       title: 'Wellora',
//       theme: ThemeData(primarySwatch: Colors.green),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
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

    // 🔹 لما الأبب يكون مفتوح و المستخدم يضغط على اللينك من الإيميل
    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    });

    // 🔹 لما الأبب يفتح أول مرة من اللينك (cold start)
    // final initialLink = await _appLinks.getInitialAppLink();
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
        // 🔸 هنا بنروح مباشرة لشاشة ResetPasswordView
        AppRouter.router.go(
          '${AppRouter.kResetPassword}?email=$email&token=$token',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'Wellora',
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
