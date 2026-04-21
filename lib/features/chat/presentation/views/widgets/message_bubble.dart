import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان بناءً على هوية "Medicare Plus"
    final Color bubbleColor =
        message.isMe ? const Color(0xFF1B4E8C) : Colors.white;
    final Color textColor = message.isMe ? Colors.white : Colors.black87;
    // final TextAlign textAlign = message.isMe ? TextAlign.right : TextAlign.left;
    final CrossAxisAlignment crossAlign =
        message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(15.r),
      topRight: Radius.circular(15.r),
      bottomLeft: message.isMe ? Radius.circular(15.r) : Radius.zero,
      bottomRight: message.isMe ? Radius.zero : Radius.circular(15.r),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      child: Column(
        crossAxisAlignment: crossAlign,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15.sp),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "${message.time.hour}:${message.time.minute}",
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
