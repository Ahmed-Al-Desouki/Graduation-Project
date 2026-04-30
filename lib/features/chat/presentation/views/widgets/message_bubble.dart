import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.senderId == currentUserId;

    final Color bubbleColor = isMe ? const Color(0xFF2563EB) : Colors.white;
    final Color textColor = isMe ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                message.type == MessageType.text ? 12.h : 4.h,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(textColor),
            ),
            SizedBox(height: 2.h),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Color textColor) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: message.fileUrl!,
            placeholder:
                (context, url) =>
                    const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      case MessageType.pdf:
        return InkWell(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf, color: textColor, size: 30.sp),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  "Medical Document.pdf",
                  style: TextStyle(color: textColor, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        );
    }
  }
}
