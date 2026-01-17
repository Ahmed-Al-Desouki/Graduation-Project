import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';

class SectionShowcaseWrapper extends StatelessWidget {
  final GlobalKey globalKey;
  final String title;
  final String description;
  final int stepIndex;
  final int totalSteps;
  final Widget child;

  const SectionShowcaseWrapper({
    super.key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.totalSteps,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: globalKey,
      width: 280.w,
      height: null,
      tooltipPosition: TooltipPosition.top,
      targetPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      container: TutorialTooltipWidget(
        title: title,
        description: description,
        currentStep: stepIndex,
        totalSteps: totalSteps,
        onNext: () {
          if (stepIndex == totalSteps) {
            ShowCaseWidget.of(context).dismiss();
          } else {
            ShowCaseWidget.of(context).next();
          }
        },
        onSkip: () => ShowCaseWidget.of(context).dismiss(),
      ),
      child: child,
    );
  }
}
