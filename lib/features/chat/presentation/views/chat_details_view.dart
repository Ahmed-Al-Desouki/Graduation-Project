import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_details_cubit/chat_details_cubit.dart';
import 'widgets/message_bubble.dart';

class ChatDetailsView extends StatefulWidget {
  final String chatId;
  final String receiverName;

  const ChatDetailsView({
    super.key,
    required this.chatId,
    required this.receiverName,
  });

  @override
  State<ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends State<ChatDetailsView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => getIt<ChatDetailsCubit>()..fetchMessages(widget.chatId),
      child: Builder(
        // ✅ الحل السحري هنا
        builder: (newContext) {
          // newContext يقع الآن تحت الـ BlocProvider
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.receiverName),
              backgroundColor: const Color(0xFF1B4E8C),
            ),
            body: Column(
              children: [
                // ✅ عرض الرسائل
                Expanded(
                  child: BlocBuilder<ChatDetailsCubit, ChatDetailsState>(
                    builder: (context, state) {
                      if (state is ChatDetailsSuccess) {
                        return ListView.builder(
                          reverse: true, // الشات يبدأ من الأسفل
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            // ✅ الوصول للعناصر بشكل عكسي (الأحدث تحت)
                            final message =
                                state.messages.reversed.toList()[index];
                            return MessageBubble(message: message);
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                // ✅ نمرر الـ newContext الذي يرى الكيوبت
                _buildMessageInput(newContext),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            backgroundColor: const Color(0xFF1B4E8C),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  // ✅ مناداة الكيوبت لإرسال الرسالة
                  context.read<ChatDetailsCubit>().sendNewMessage(
                    widget.chatId,
                    _messageController.text,
                  );
                  _messageController.clear(); // مسح الحقل بعد الإرسال
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
