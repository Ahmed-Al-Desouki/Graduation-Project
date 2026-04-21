import 'package:flutter/material.dart';

// void showSnackBar(BuildContext context, String message, Color backgroundColor) {
//   ScaffoldMessenger.of(context).hideCurrentSnackBar();
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       behavior: SnackBarBehavior.floating,
//       elevation: 8,
//       backgroundColor: backgroundColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       content: Row(
//         children: [
//           // const Icon(Icons.check_circle, color: Colors.white, size: 28),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               message,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       duration: const Duration(milliseconds: 1500),
//     ),
//   );
// }

void showSnackBar(BuildContext context, String message, Color backgroundColor) {
  // 1. فلترة الرسائل التقنية لكلام "بشري"
  String friendlyMessage = message;
  IconData icon = Icons.info_outline;

  if (message.contains("exception already exists")) {
    // friendlyMessage = "هذا اليوم مسجل بالفعل كإجازة أو ساعات خاصة.";
    icon = Icons.warning_amber_rounded;
  } else if (backgroundColor == Colors.red ||
      message.toLowerCase().contains("error")) {
    icon = Icons.error_outline;
  } else if (backgroundColor == Colors.green) {
    icon = Icons.check_circle_outline;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0, // هنخليها 0 ونستخدم Container للحواف
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(
            alpha: 0.95,
          ), // لون شفاف بسيط لشياكة أكتر
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friendlyMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
  );
}
