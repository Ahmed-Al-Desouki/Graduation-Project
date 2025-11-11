import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
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
  final List<String> _nameLetters = ['M', 'e', 'd', 'C', 'a', 'r', 'e', '+'];
  static const Color darkBlue = Color(0xFF1B4E8C);
  static const Color brightGreen = Color(0xFF4CAF50);

  static const double nameAppearanceDurationFactor = 0.68;
  static const double logoAppearanceDurationFactor = 0.15;
  static const double totalAppearanceFactor =
      nameAppearanceDurationFactor + logoAppearanceDurationFactor;
  static const double fadeOutStartTime = 0.93;
  static const int totalDurationMs = 5500;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: totalDurationMs),
      vsync: this,
    );

    final double letterSegmentDuration =
        nameAppearanceDurationFactor / _nameLetters.length;

    for (int i = 0; i < _nameLetters.length; i++) {
      final double begin = i * letterSegmentDuration;
      final double end = (i + 1) * letterSegmentDuration;
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, end, curve: Curves.easeIn),
          ),
        ),
      );
    }

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          nameAppearanceDurationFactor,
          totalAppearanceFactor,
          curve: Curves.easeIn,
        ),
      ),
    );

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
        final biometricEnabled = settingsBox.get(
          'biometric_enabled',
          defaultValue: false,
        );

        final accessToken = await SecureStorageHelper.getAccessToken();
        final refreshToken = await SecureStorageHelper.getRefreshToken();
        final role = await SecureStorageHelper.getUserRole();
        final uid = await SecureStorageHelper.getUserId();

        print("access ${accessToken}");
        print("refreshToken ${refreshToken}");
        // لو مفيش توكنات أساسًا → روح على اللوجن
        if (accessToken == null || refreshToken == null) {
          context.go(AppRouter.kLogin);
          return;
        }

        final authRepo = getIt<AuthRepositoryimpl>();
        final validityResult = await authRepo.checkAccessValidity(accessToken);

        final isAccessValid = validityResult.fold(
          (failure) => false,
          (isValid) => isValid,
        );

        if (isAccessValid) {
          if (biometricEnabled) {
            context.go(AppRouter.kBiometric);
          } else {
            if (role == 'Doctor') {
              AppRouter.router.go(AppRouter.kHomeDoctor);
            } else {
              AppRouter.router.go(AppRouter.kHomePatient);
            }
            // context.go(AppRouter.kSettings);
          }
        } else {
          final validityResult_RefreshToken = await authRepo
              .checkRefreshValidity(refreshToken);
          final isRefreshValid = validityResult_RefreshToken.fold(
            (failure) => false,
            (isValid) => isValid,
          );
          if (isRefreshValid) {
            final refreshResult = await authRepo.refreshToken(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            await refreshResult.fold(
              (failure) async {
                await SecureStorageHelper.clearTokens();
                context.go(AppRouter.kLogin);
              },
              (tokenModel) async {
                await SecureStorageHelper.updateTokens(
                  newAccessToken: tokenModel.accessToken,
                  newRefreshToken: tokenModel.refreshToken,
                );
                Map<String, dynamic> payload = JwtDecoder.decode(
                  tokenModel.accessToken,
                );
                final role =
                    (payload['role'] ?? payload['Role'] ?? '')
                        .toString()
                        .toLowerCase();
                final uid =
                    (payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '')
                        .toString();
                await SecureStorageHelper.saveUserRoleAndId(
                  role: role,
                  userId: uid,
                );

                if (biometricEnabled) {
                  context.go(AppRouter.kBiometric);
                } else {
                  if (role == 'Doctor') {
                    AppRouter.router.go(AppRouter.kHomeDoctor);
                  } else {
                    AppRouter.router.go(AppRouter.kHomePatient);
                  }
                  // context.go(AppRouter.kSettings);
                }
              },
            );
          } else {
            await SecureStorageHelper.clearTokens();
            context.go(AppRouter.kLogin);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLetter(String letter, int index) {
    Color color = (index < 3) ? darkBlue : brightGreen;
    Widget text = Text(
      letter,
      style: TextStyle(
        color: color,
        fontSize: 40.sp,
        fontWeight: FontWeight.bold,
      ),
    );
    if (letter == '+') {
      text = Transform.translate(
        offset: Offset(0, -8.h),
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontSize: 28.sp,
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
                  width: 0.5.sw, // **تم تعديل width ليكون 50% من عرض الشاشة**
                  height: 0.5.sw, // **تم تعديل height ليكون متناسب مع العرض**
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: 0.05.sh,
              ), // **مسافة ديناميكية 5% من ارتفاع الشاشة**
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // **تم التوسيط**
                children: [
                  for (int i = 0; i < _nameLetters.length; i++)
                    _buildLetter(_nameLetters[i], i),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
