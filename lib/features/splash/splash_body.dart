import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
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
    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed && mounted) {
    //     AppRouter.router.go(AppRouter.kLogin);
    //   }
    // });
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        var settingsBox = await Hive.openBox('settings');
        bool biometricEnabled = settingsBox.get(
          'biometric_enabled',
          defaultValue: false,
        );

        if (biometricEnabled) {
          context.go(AppRouter.kBiometric);
        } else {
          context.go(AppRouter.kLogin);
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
      style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.bold),
    );
    if (letter == '+') {
      text = Transform.translate(
        offset: const Offset(0, -8),
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontSize: 28,
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
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisSize: MainAxisSize.min,
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
