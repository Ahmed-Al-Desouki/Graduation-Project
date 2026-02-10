import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_preview_entity.dart';
// افترضنا وجود كلاس لتنسيق الوقت
// import 'package:intl/intl.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatPreviewEntity chat;
  final VoidCallback onTap;

  const ChatItemWidget({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundImage:
            chat.receiverImage != null
                ? NetworkImage(chat.receiverImage!)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.receiverName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute}", // يفضل استخدام intl هنا
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                // ✅ المنطق الذي طلبته: You أو اسم الدكتور
                "${chat.isLastMessageFromMe ? 'You: ' : '${chat.receiverName.split(' ')[0]}: '}${chat.lastMessage}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unreadCount > 0 ? Colors.black : Colors.grey,
                  fontWeight:
                      chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                ),
              ),
            ),
            // ✅ الـ Unread Count Badge
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B4E8C),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
