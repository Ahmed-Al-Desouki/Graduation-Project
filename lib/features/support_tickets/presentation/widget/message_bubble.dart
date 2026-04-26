// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';

// class MessageBubble extends StatelessWidget {
//   final TicketMessageEntity message;
//   const MessageBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     // في أبلكيشن المريض: لو مش من الأدمن، يبقى أنا اللي باعتها
//     bool isMe = !message.isFromAdmin;

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         // ... نفس الـ UI اللي بعته مع تغيير الألوان
//         color: isMe ? const Color(0xFF0D9488) : Colors.white,
//         // أضف shadow خفيف للرسائل اللي مش مني عشان تبان على الخلفية الرمادي
//         decoration: BoxDecoration(
//           boxShadow:
//               isMe
//                   ? []
//                   : [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 5,
//                     ),
//                   ],
//           // ... باقي الـ styling
//         ),
//         child: Text(
//           message.content,
//           style: TextStyle(color: isMe ? Colors.white : Colors.black87),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';
import 'package:intl/intl.dart'; // تأكد من إضافة intl في الـ pubspec

class MessageBubble extends StatelessWidget {
  final TicketMessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // في أبلكيشن المريض: لو مش من الأدمن، يبقى أنا اللي باعتها (تظهر يمين)
    bool isMe = !message.isFromAdmin;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ✅ اللون لازم يتحط جوه الـ BoxDecoration طالما في Shadow أو BorderRadius
          color: isMe ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
