import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
import 'package:intl/intl.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatEntity chat;
  final bool isDoctor;
  final VoidCallback onTap;

  const ChatItemWidget({
    super.key,
    required this.chat,
    required this.isDoctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = isDoctor ? chat.patientName : chat.doctorName;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),
          if (chat.isActive)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 16.sp,
          color: const Color(0xFF1E293B),
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          chat.lastMessage ?? "Start a conversation...",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
            fontSize: 13.sp,
            fontWeight:
                chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageTime != null)
            Text(
              DateFormat('hh:mm a').format(chat.lastMessageTime!),
              style: TextStyle(
                color:
                    chat.unreadCount > 0
                        ? const Color(0xFF2563EB)
                        : Colors.grey,
                fontSize: 11.sp,
                fontWeight:
                    chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          SizedBox(height: 6.h),
          if (chat.unreadCount > 0)
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
