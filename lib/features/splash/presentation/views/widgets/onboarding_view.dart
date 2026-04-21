import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Find Your Doctor",
      "desc":
          "Search for top doctors and book appointments. Our system generates real-time slots for you.",
      "image": "assets/lottie/Search Doctor.json",
    },
    {
      "title": "Medical QR Code",
      "desc":
          "Share your medical history instantly via QR. Doctors can view it on the web even without the app.",
      "image": "assets/lottie/QR Code.json",
    },
    {
      "title": "Smart Reminders",
      "desc":
          "Dynamic reminders that work offline and sync across all your devices automatically.",
      "image": "assets/lottie/Alarm Clock.json",
    },
    {
      "title": "Secure & Fast Access",
      "desc":
          "Protect your data with Biometric login. Fast, secure, and always accessible when you need it.",
      "image": "assets/lottie/Fingerlog biometric scan.json",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  "Skip",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(
                    _onboardingData[index]['title']!,
                    _onboardingData[index]['desc']!,
                    _onboardingData[index]['image']!,
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4E8C),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    var box = await Hive.openBox('settings');
    await box.put('onboarding_seen', true);
    if (mounted) context.go(AppRouter.kLogin);
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? const Color(0xFF1B4E8C)
                : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPageContent(String title, String desc, String lottiePath) {
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottiePath,
            height: 250.h,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),

          SizedBox(height: 40.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B4E8C),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
