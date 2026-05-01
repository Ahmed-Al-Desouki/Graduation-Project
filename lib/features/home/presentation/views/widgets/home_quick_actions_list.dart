import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/quick_action_card.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:go_router/go_router.dart';

class HomeQuickActionsList extends StatelessWidget {
  final GlobalKey searchDoctorKey;
  final GlobalKey remindersKey;
  final GlobalKey historyKey;

  const HomeQuickActionsList({
    super.key,
    required this.searchDoctorKey,
    required this.remindersKey,
    required this.historyKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _buildShowcaseAction(
        //   context,
        //   key: searchDoctorKey,
        //   step: 2,
        //   title: 'Find a Doctor',
        //   desc: 'Book appointments with specialists.',
        //   child: QuickActionCard(
        //     onTap: () {},
        //     title: 'Search for Doctors',
        //     subtitle: 'Schedule with your doctor',
        //     gradientColor: const Color(0xFF9333EA),
        //     imageAsset: Assets.imagesClipartDoctorPerson1,
        //     isSvg: false,
        //   ),
        // ),
        SizedBox(height: 20.h),

        _buildShowcaseAction(
          context,
          key: remindersKey,
          step: 3,
          title: 'Medicine Reminders',
          desc: 'Track your medications.',
          child: QuickActionCard(
            iconColor: const Color(0xFF0852F3),
            onTap: () => context.go(AppRouter.kReminder),
            title: 'Reminders',
            subtitle: 'Update your Reminders',
            gradientColor: const Color(0xFF0852F3),
            imageAsset: Assets.imagesReminderSvgrepoCom,
          ),
        ),

        SizedBox(height: 20.h),

        _buildShowcaseAction(
          context,
          key: historyKey,
          step: 4,
          title: 'Medical History',
          desc: 'Access your past reports.',
          child: QuickActionCard(
            onTap: () => context.go(AppRouter.kMedicalHistory),
            title: 'Medical History',
            subtitle: 'View your health history',
            gradientColor: const Color(0xFF23B82A),
            imageAsset: Assets.imagesMedicalRecordsSvgrepoCom,
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseAction(
    BuildContext context, {
    required GlobalKey key,
    required int step,
    required String title,
    required String desc,
    required Widget child,
  }) {
    return Showcase.withWidget(
      key: key,
      width: 270.w,
      tooltipPosition: TooltipPosition.top,
      container: TutorialTooltipWidget(
        currentStep: step,
        totalSteps: 4,
        title: title,
        description: desc,
        onNext:
            () =>
                step == 4
                    ? ShowCaseWidget.of(context).dismiss()
                    : ShowCaseWidget.of(context).next(),
        onSkip: () => ShowCaseWidget.of(context).dismiss(),
      ),
      height: null,
      child: child,
    );
  }
}
