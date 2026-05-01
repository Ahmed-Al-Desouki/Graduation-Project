import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  static const double logoStart = 0.0;
  static const double logoEnd = 0.4;
  static const double textStart = 0.4;
  static const double textEnd = 0.8;
  static const double fadeOutStartTime = 0.9;
  static const int totalDurationMs = 3000;

  SignalRService get signalRService => getIt<SignalRService>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: totalDurationMs),
      vsync: this,
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(logoStart, logoEnd, curve: Curves.easeInOut),
      ),
    );

    for (int i = 0; i < _wellnessLetters.length; i++) {
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              textStart,
              textStart + 0.2,
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < _everywhereLetters.length; i++) {
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              textStart + 0.2,
              textEnd,
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
    }

    _globalFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(fadeOutStartTime, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
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

        if (!mounted) return;

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
    });
  }

  Future<void> _navigateToHome() async {
    final roleData = await SecureStorageHelper.getUserRole();
    final role = roleData['role']?.toLowerCase();
    final token = await SecureStorageHelper.getAccessToken();

    // 2. لو التوكن موجود، ابدأ الـ SignalR
    if (token != null) {
      await signalRService.init(token); // يفضل تعمل await لو عاوز تضمن إنه بدأ
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

  Widget _buildLetter(String letter, int index, Color color) {
    Widget text = Text(
      letter,
      style: TextStyle(
        color: color,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
    if (letter == '+') {
      text = Transform.translate(
        offset: Offset(0, -3.h),
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return FadeTransition(opacity: _letterAnimations[index], child: text);
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
                  Assets.imagesLogooo,
                  width: 0.7.sw,
                  fit: BoxFit.contain,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _wellnessLetters.length; i++)
                    _buildLetter(_wellnessLetters[i], i, darkBlue),
                  SizedBox(width: 6.w),
                  for (int i = 0; i < _everywhereLetters.length; i++)
                    _buildLetter(
                      _everywhereLetters[i],
                      i + _wellnessLetters.length,
                      darkBlue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
