import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:go_router/go_router.dart';

class MedicalHistoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey drawerBtnKey;
  final VoidCallback onQrPressed;
  final bool showQrButton;
  final int totalSteps;
  final bool isDoctorView;

  const MedicalHistoryAppBar({
    super.key,
    required this.scaffoldKey,
    required this.drawerBtnKey,
    required this.onQrPressed,
    this.showQrButton = false,
    required this.totalSteps,
    required this.isDoctorView,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('My Medical History', style: AppStyles.styleSemiBold18Dark),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Color(0xFF111827),
        ),
        onPressed: () {
          // ❌ بدلاً من: context.go(AppRouter.kHomePatient)
          // ✅ استخدم:
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // لو مفيش شاشة يرجع لها (حالة احتياطية) يروح للهوم المناسب
            context.go(
              isDoctorView ? AppRouter.kHomeDoctor : AppRouter.kHomePatient,
            );
          }
        },
      ),
      actions: [
        if (showQrButton)
          IconButton(
            icon: const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: onQrPressed,
          ),
        const SizedBox(width: 8),
        Showcase.withWidget(
          key: drawerBtnKey,
          height: 160,
          width: 280.w,
          container: TutorialTooltipWidget(
            title: 'Quick Navigation',
            description: 'Jump between sections easily.',
            currentStep: 1,
            totalSteps: totalSteps,
            onNext: () => ShowCaseWidget.of(context).next(),
            onSkip: () => ShowCaseWidget.of(context).dismiss(),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.menu_open_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
