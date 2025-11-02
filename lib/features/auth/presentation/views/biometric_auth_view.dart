// // import 'package:flutter/material.dart';
// // import 'package:local_auth/local_auth.dart';

// // class BiometricAuthScreen extends StatefulWidget {
// //   final VoidCallback onAuthenticated;

// //   const BiometricAuthScreen({super.key, required this.onAuthenticated});

// //   @override
// //   State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
// // }

// // class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
// //   final LocalAuthentication auth = LocalAuthentication();

// //   Future<void> _authenticate() async {
// //     try {
// //       bool canCheck = await auth.canCheckBiometrics;
// //       if (!canCheck) return;

// //       bool authenticated = await auth.authenticate(
// //         localizedReason: 'من فضلك قم بتأكيد هويتك بالبصمة أو الوجه',
// //         options: const AuthenticationOptions(
// //           biometricOnly: false,
// //           stickyAuth: true,
// //         ),
// //       );

// //       if (authenticated) {
// //         widget.onAuthenticated();
// //       }
// //     } catch (e) {
// //       print('Auth error: $e');
// //     }
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _authenticate();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:graduation_project/core/utils/app_router.dart';

// class BiometricAuthScreen extends StatefulWidget {
//   const BiometricAuthScreen({super.key});

//   @override
//   State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
// }

// class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
//   final LocalAuthentication auth = LocalAuthentication();

//   @override
//   void initState() {
//     super.initState();
//     _authenticate();
//   }

//   // Future<void> _authenticate() async {
//   //   try {
//   //     bool authenticated = await auth.authenticate(
//   //       localizedReason: 'سجّل الدخول بالبصمة أو الوجه أو رقم الجهاز',
//   //       options: const AuthenticationOptions(biometricOnly: false),
//   //     );

//   //     if (authenticated && mounted) {
//   //       // بعد نجاح البصمة يفتح التطبيق الرئيسي
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder:
//   //               (_) => MaterialApp.router(
//   //                 routerConfig: AppRouter.router,
//   //                 debugShowCheckedModeBanner: false,
//   //                 title: 'Wellora',
//   //                 theme: ThemeData(primarySwatch: Colors.green),
//   //               ),
//   //         ),
//   //       );
//   //     } else {
//   //       // لو فشل أو رفض، يرجع لتسجيل الدخول
//   //       context.go(AppRouter.kLogin);
//   //     }
//   //   } catch (e) {
//   //     debugPrint('❌ Biometric error: $e');
//   //     if (mounted) context.go(AppRouter.kLogin);
//   //   }
//   // }

//   Future<void> _authenticate() async {
//     try {
//       bool authenticated = await auth.authenticate(
//         localizedReason: 'سجّل الدخول بالبصمة أو الوجه أو رقم الجهاز',
//         options: const AuthenticationOptions(biometricOnly: false),
//       );

//       if (authenticated && mounted) {
//         // بعد نجاح البصمة -> يدخل التطبيق مباشرة (الـ router بيبدأ من Splash)
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (_) => MaterialApp.router(
//                   routerConfig: AppRouter.router,
//                   debugShowCheckedModeBanner: false,
//                   title: 'Wellora',
//                   theme: ThemeData(primarySwatch: Colors.green),
//                 ),
//           ),
//         );
//       } else {
//         // لو فشل أو رفض -> ارجع يدوي لصفحة اللوجين
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (_) => MaterialApp.router(
//                   routerConfig: AppRouter.router,
//                   debugShowCheckedModeBanner: false,
//                   title: 'Wellora',
//                   theme: ThemeData(primarySwatch: Colors.green),
//                 ),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Biometric error: $e');
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (_) => MaterialApp.router(
//                   routerConfig: AppRouter.router,
//                   debugShowCheckedModeBanner: false,
//                   title: 'Wellora',
//                   theme: ThemeData(primarySwatch: Colors.green),
//                 ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'سجّل الدخول بالبصمة أو الوجه أو رمز الجهاز',
        options: const AuthenticationOptions(biometricOnly: false),
      );

      if (authenticated && mounted) {
        context.go(AppRouter.kSettings);
      } else {
        // فشل البصمة → يرجع لشاشة تسجيل الدخول
        context.go(AppRouter.kLogin);
      }
    } catch (e) {
      debugPrint('❌ Biometric error: $e');
      if (mounted) context.go(AppRouter.kLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
