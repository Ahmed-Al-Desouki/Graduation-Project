// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
// import 'package:showcaseview/showcaseview.dart';

// class SectionShowcaseWrapper extends StatelessWidget {
//   final GlobalKey globalKey;
//   final String title;
//   final String description;
//   final int stepIndex;
//   final int totalSteps;
//   final Widget child;

//   const SectionShowcaseWrapper({
//     super.key,
//     required this.globalKey,
//     required this.title,
//     required this.description,
//     required this.stepIndex,
//     required this.totalSteps,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Showcase.withWidget(
//       key: globalKey,
//       // ✅ ظبطنا المقاسات هنا عشان متخرجش برا الشاشة
//       height: 160,
//       width: 260,
//       // ✅ targetPadding بيخلي فيه مسافة بين العنصر والفقاعة عشان ميتزنقوش
//       targetPadding: const EdgeInsets.all(4),
//       container: TutorialTooltipWidget(
//         title: title,
//         description: description,
//         currentStep: stepIndex,
//         totalSteps: totalSteps,
//         onNext: () {
//           // لو آخر خطوة نقفل، غير كدا نكمل
//           if (stepIndex == totalSteps) {
//             ShowCaseWidget.of(context).dismiss();
//           } else {
//             ShowCaseWidget.of(context).next();
//           }
//         },
//         onSkip: () => ShowCaseWidget.of(context).dismiss(),
//       ),
//       child: child,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
// import 'package:showcaseview/showcaseview.dart';

// class SectionShowcaseWrapper extends StatelessWidget {
//   final GlobalKey globalKey;
//   final String title;
//   final String description;
//   final int stepIndex;
//   final int totalSteps;
//   final Widget child;

//   const SectionShowcaseWrapper({
//     super.key,
//     required this.globalKey,
//     required this.title,
//     required this.description,
//     required this.stepIndex,
//     required this.totalSteps,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Showcase.withWidget(
//       key: globalKey,
//       height: 150,
//       width: 250,
//       // ✅ ده اللي بيخلي الفقاعة تظهر فوق المحتوى لو تحت، وتحت المحتوى لو فوق
//       tooltipPosition: TooltipPosition.top,
//       // ✅ بيدي براح للكارد نفسه
//       targetPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       container: TutorialTooltipWidget(
//         title: title,
//         description: description,
//         currentStep: stepIndex,
//         totalSteps: totalSteps,
//         onNext: () {
//           if (stepIndex == totalSteps) {
//             ShowCaseWidget.of(context).dismiss();
//           } else {
//             ShowCaseWidget.of(context).next();
//           }
//         },
//         onSkip: () => ShowCaseWidget.of(context).dismiss(),
//       ),
//       child: child,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ مهم جداً
import 'package:showcaseview/showcaseview.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart'; // تأكد من المسار

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
      // ❌ شيلنا الـ height و width الثابتين عشان المحتوى ياخد راحته
      // ونستخدم constraints بدالهم
      width: 280.w,
      height: null, // سيب الارتفاع ديناميكي حسب النص
      // ✅ ضبط مكان الفقاعة (تلقائي هو الأفضل، لكن ممكن نتحكم فيه لو الشاشة زحمة)
      tooltipPosition: TooltipPosition.top,

      // ✅ مسافة أمان عشان الفقاعة متلزقش في العنصر
      targetPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),

      // ✅ الشكل المخصص للفقاعة
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
