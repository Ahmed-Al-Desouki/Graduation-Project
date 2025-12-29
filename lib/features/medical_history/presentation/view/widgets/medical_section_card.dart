// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/medical_history/presentation/view/widgets/dotted_add_button.dart';

// class MedicalSectionCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color themeColor; // اللون الأساسي (للأيقونة والزرار)
//   final Color? iconBgColor; // لو عاوز خلفية الأيقونة لون مخصص (اختياري)
//   final List<Widget> children; // الكروت اللي هتتعرض
//   final VoidCallback? onAddTap; // زرار الإضافة (لو null مش هيظهر)
//   final VoidCallback? onViewAllTap; // زرار عرض الكل (لو null مش هيظهر)
//   final String emptyMessage;

//   const MedicalSectionCard({
//     super.key,
//     required this.title,
//     required this.icon,
//     required this.themeColor,
//     this.iconBgColor,
//     required this.children,
//     this.onAddTap,
//     this.onViewAllTap,
//     this.emptyMessage = "No records found.",
//   });

//   @override
//   Widget build(BuildContext context) {
//     // تحديد لون الخلفية للأيقونة لو مش مبعوت
//     final bgColor = iconBgColor ?? themeColor.withOpacity(0.1);

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- Header ---
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: bgColor,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(icon, color: themeColor, size: 20),
//                     ),
//                     const SizedBox(width: 12),
//                     Flexible(
//                       child: Text(
//                         title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (onViewAllTap != null)
//                 TextButton(
//                   onPressed: onViewAllTap,
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     minimumSize: const Size(50, 30),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: const Text(
//                     "View All",
//                     style: TextStyle(
//                       color: Color(0xFF2563EB),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // --- Body (Content or Empty) ---
//           if (children.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: Column(
//                   children: [
//                     Icon(Icons.notes, size: 40, color: Colors.grey.shade200),
//                     const SizedBox(height: 8),
//                     Text(
//                       emptyMessage,
//                       style: TextStyle(
//                         color: Colors.grey.shade400,
//                         fontSize: 14,
//                         fontStyle: FontStyle.italic,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             ...children,

//           // --- Footer (Add Button) ---
//           if (onAddTap != null) ...[
//             const SizedBox(height: 20),
//             DottedAddButton(
//               onTap: onAddTap!,
//               text:
//                   "Add New ${title.replaceAll('Current ', '')}", // ذكاء بسيط لحذف كلمات زائدة
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/dotted_add_button.dart';

class MedicalSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color themeColor;
  final Color? iconBgColor;
  final List<Widget> children;
  final VoidCallback? onAddTap;
  final VoidCallback? onViewAllTap;
  final Widget? actionWidget; // ✅ الإضافة الجديدة
  final String emptyMessage;

  const MedicalSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    this.iconBgColor,
    required this.children,
    this.onAddTap,
    this.onViewAllTap,
    this.actionWidget, // ✅
    this.emptyMessage = "No records found.",
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBgColor ?? themeColor.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: themeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // الأولوية: زرار مخصص > زرار عرض الكل
              if (actionWidget != null)
                actionWidget!
              else if (onViewAllTap != null)
                TextButton(
                  onPressed: onViewAllTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // --- Body ---
          if (children.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(Icons.notes, size: 40, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...children,

          // --- Footer (Add Button) ---
          if (onAddTap != null) ...[
            const SizedBox(height: 20),
            DottedAddButton(
              onTap: onAddTap!,
              text: "Add New ${title.replaceAll('Current ', '')}",
            ),
          ],
        ],
      ),
    );
  }
}
