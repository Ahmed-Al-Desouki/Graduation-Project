import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';

// class SplashBody extends StatefulWidget {
//   const SplashBody({super.key});

//   @override
//   State<SplashBody> createState() => _SplashBodyState();
// }

// class _SplashBodyState extends State<SplashBody>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final List<Animation<double>> _letterAnimations = [];
//   late Animation<double> _logoOpacityAnimation;
//   late Animation<double> _globalFadeOutAnimation;

//   final List<String> _wellnessLetters = ['Wellness'];
//   final List<String> _everywhereLetters = ['Everywhere'];

//   static const Color darkBlue = Color(0xFF1B4E8C);

//   static const double logoStart = 0.0;
//   static const double logoEnd = 0.4;
//   static const double textStart = 0.4;
//   static const double textEnd = 0.8;
//   static const double fadeOutStartTime = 0.9;
//   static const int totalDurationMs = 3000;

//   SignalRService get signalRService => getIt<SignalRService>();

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: totalDurationMs),
//       vsync: this,
//     );

//     _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(logoStart, logoEnd, curve: Curves.easeInOut),
//       ),
//     );

//     for (int i = 0; i < _wellnessLetters.length; i++) {
//       _letterAnimations.add(
//         Tween<double>(begin: 0.0, end: 1.0).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(
//               textStart,
//               textStart + 0.2,
//               curve: Curves.easeIn,
//             ),
//           ),
//         ),
//       );
//     }

//     for (int i = 0; i < _everywhereLetters.length; i++) {
//       _letterAnimations.add(
//         Tween<double>(begin: 0.0, end: 1.0).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: const Interval(
//               textStart + 0.2,
//               textEnd,
//               curve: Curves.easeIn,
//             ),
//           ),
//         ),
//       );
//     }

//     _globalFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(fadeOutStartTime, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();

//     _controller.addStatusListener((status) async {
//       if (status == AnimationStatus.completed && mounted) {
//         final settingsBox = await Hive.openBox('settings');
//         final onboardingSeen = settingsBox.get(
//           'onboarding_seen',
//           defaultValue: false,
//         );
//         final biometricEnabled = settingsBox.get(
//           'biometric_enabled',
//           defaultValue: false,
//         );

//         final sessionManager = getIt<SessionManager>();
//         final sessionStatus = await sessionManager.validateSession();

//         if (!mounted) return;

//         if (sessionStatus == SessionStatus.valid) {
//           if (biometricEnabled) {
//             context.go(AppRouter.kBiometric);
//           } else {
//             await _navigateToHome();
//           }
//         } else {
//           if (onboardingSeen) {
//             context.go(AppRouter.kLogin);
//           } else {
//             context.go(AppRouter.kOnboarding);
//           }
//         }
//       }
//     });
//   }

//   Future<void> _navigateToHome() async {
//     final roleData = await SecureStorageHelper.getUserRole();
//     final role = roleData['role']?.toLowerCase();
//     final token = await SecureStorageHelper.getAccessToken();

//     // 2. لو التوكن موجود، ابدأ الـ SignalR
//     if (token != null) {
//       await signalRService.init(token); // يفضل تعمل await لو عاوز تضمن إنه بدأ
//     }

//     if (role == 'doctor') {
//       AppRouter.router.go(AppRouter.kDoctorProfileGate);
//     } else {
//       AppRouter.router.go(AppRouter.kHomePatient);
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildLetter(String letter, int index, Color color) {
//     Widget text = Text(
//       letter,
//       style: TextStyle(
//         color: color,
//         fontSize: 18.sp,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//     if (letter == '+') {
//       text = Transform.translate(
//         offset: Offset(0, -3.h),
//         child: Text(
//           letter,
//           style: TextStyle(
//             color: color,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }
//     return FadeTransition(opacity: _letterAnimations[index], child: text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _globalFadeOutAnimation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               FadeTransition(
//                 opacity: _logoOpacityAnimation,
//                 child: Image.asset(
//                   Assets.imagesLogooo,
//                   width: 0.7.sw,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   for (int i = 0; i < _wellnessLetters.length; i++)
//                     _buildLetter(_wellnessLetters[i], i, darkBlue),
//                   SizedBox(width: 6.w),
//                   for (int i = 0; i < _everywhereLetters.length; i++)
//                     _buildLetter(
//                       _everywhereLetters[i],
//                       i + _wellnessLetters.length,
//                       darkBlue,
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _letterAnimations = [];
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _globalFadeOutAnimation;

  final List<String> _wellnessLetters = ['Wellness'];
  final List<String> _everywhereLetters = ['Everywhere'];
  static const Color darkBlue = Color(0xFF1B4E8C);
  static const int totalDurationMs = 3000;

  @override
  void initState() {
    super.initState();
    // 1. شيل الـ Native Splash فوراً لأننا بدأنا نرسم الـ SplashBody
    FlutterNativeSplash.remove();

    _setupAnimations();
    _initializeApp(); // 🚀 تشغيل المتوازي يبدأ هنا
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: totalDurationMs),
      vsync: this,
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // تعريف أنيميشن الحروف
    for (
      int i = 0;
      i < (_wellnessLetters.length + _everywhereLetters.length);
      i++
    ) {
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(0.4, 0.8, curve: Curves.easeIn),
          ),
        ),
      );
    }

    _globalFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 🚀 الميثود اللي بتشغل الأنيميشن والـ Logic مع بعض
  Future<void> _initializeApp() async {
    try {
      // 🚀 الحل هنا: إضافة <dynamic> لتجنب مشكلة الـ Type Casting
      final results = await Future.wait<dynamic>([
        _controller.forward(),
        _performAppLogic(),
      ]);

      if (mounted) {
        // results[1] هو اللي شايل بيانات الـ Logic (الخريطة)
        _handleNavigation(results[1] as Map<String, dynamic>);
      }
    } catch (e) {
      // 🛡️ لو حصل أي خطأ لا قدر الله، انقل اليوزر للوجن عشان ميفضلش معلق
      debugPrint("Splash Error: $e");
      if (mounted) context.go(AppRouter.kLogin);
    }
  }

  // ميثود الفحص (Logic)
  Future<Map<String, dynamic>> _performAppLogic() async {
    final settingsBox = await Hive.openBox('settings');
    final onboardingSeen = settingsBox.get(
      'onboarding_seen',
      defaultValue: false,
    );
    final biometricEnabled = settingsBox.get(
      'biometric_enabled',
      defaultValue: false,
    );

    final sessionManager = getIt<SessionManager>();
    final sessionStatus = await sessionManager.validateSession();

    return {
      'onboardingSeen': onboardingSeen,
      'biometricEnabled': biometricEnabled,
      'sessionStatus': sessionStatus,
    };
  }

  // ميثود الانتقال بناءً على البيانات
  void _handleNavigation(Map<String, dynamic> data) async {
    final sessionStatus = data['sessionStatus'];
    final biometricEnabled = data['biometricEnabled'];
    final onboardingSeen = data['onboardingSeen'];

    if (sessionStatus == SessionStatus.valid) {
      if (biometricEnabled) {
        context.go(AppRouter.kBiometric);
      } else {
        await _navigateToHome();
      }
    } else {
      if (onboardingSeen) {
        context.go(AppRouter.kLogin);
      } else {
        context.go(AppRouter.kOnboarding);
      }
    }
  }

  Future<void> _navigateToHome() async {
    final roleData = await SecureStorageHelper.getUserRole();
    final role = roleData['role']?.toLowerCase();
    final token = await SecureStorageHelper.getAccessToken();

    if (token != null) {
      // بنبدأ الـ SignalR في الخلفية عشان ميعطلش الدخول للهوم
      getIt<SignalRService>().init(token);
    }

    if (role == 'doctor') {
      AppRouter.router.go(AppRouter.kDoctorProfileGate);
    } else {
      AppRouter.router.go(AppRouter.kHomePatient);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _globalFadeOutAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _logoOpacityAnimation,
                child: Image.asset(
                  Assets.imagesLogooo, // تأكد من المسار
                  width: 0.7.sw,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // هنا بنعرض الكلمات كاملة زي ما أنت عاملها
                  _buildTextGroup(_wellnessLetters[0], 0),
                  SizedBox(width: 6.w),
                  _buildTextGroup(_everywhereLetters[0], 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextGroup(String text, int index) {
    return FadeTransition(
      opacity: _letterAnimations[index],
      child: Text(
        text,
        style: TextStyle(
          color: darkBlue,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
