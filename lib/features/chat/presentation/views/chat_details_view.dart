import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_details_cubit/chat_details_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/message_bubble.dart';

class ChatDetailsView extends StatefulWidget {
  final String chatId;
  final String receiverName;
  final String currentUserId;
  final bool isDoctor;
  final DateTime? lastReadTimestamp;

  const ChatDetailsView({
    super.key,
    required this.chatId,
    required this.receiverName,
    required this.currentUserId,
    required this.isDoctor,
    this.lastReadTimestamp,
  });

  @override
  State<ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends State<ChatDetailsView> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatDetailsCubit>().listenToMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatDetailsCubit, ChatDetailsState>(
      listener: (context, state) {
        if (state is ChatDetailsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        bool isActive = true;
        if (state is ChatDetailsSuccess) isActive = state.isActive;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0.5,
            title: Text(
              widget.receiverName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF2563EB),
            centerTitle: true,
            actions: [
              if (widget.isDoctor)
                IconButton(
                  icon: Icon(
                    isActive ? Icons.lock_open : Icons.lock,
                    color: Colors.white,
                  ),
                  onPressed:
                      () => context.read<ChatDetailsCubit>().toggleChatStatus(
                        widget.chatId,
                        !isActive,
                      ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessagesList(state)),
              if (state is ChatDetailsUploading)
                const LinearProgressIndicator(),

              isActive ? _buildMessageInput(context) : _buildChatClosedWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(ChatDetailsState state) {
    if (state is ChatDetailsSuccess) {
      if (state.messages.isEmpty) return _buildChatClosedWidget();

      return ListView.builder(
        reverse: true,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];

          bool showMarker = false;
          if (widget.lastReadTimestamp != null) {
            final isNew = message.timestamp.isAfter(widget.lastReadTimestamp!);
            if (isNew &&
                (index == state.messages.length - 1 ||
                    !state.messages[index + 1].timestamp.isAfter(
                      widget.lastReadTimestamp!,
                    ))) {
              showMarker = true;
            }
          }

          return Column(
            children: [
              if (showMarker) _buildUnreadMarker(),
              MessageBubble(
                message: message,
                currentUserId: widget.currentUserId,
              ),
            ],
          );
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildUnreadMarker() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        "New Messages",
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChatClosedWidget() {
    return Container(
      padding: EdgeInsets.all(16.h),
      color: Colors.grey[100],
      child: Text(
        "this chat is closed by the doctor and you can't send messages anymore. and after you book an appointment you can send messages again",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2563EB),
            ),
            onPressed: () => _pickAndSendImage(context),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  context.read<ChatDetailsCubit>().sendNewMessage(
                    chatId: widget.chatId,
                    senderId: widget.currentUserId,
                    text: _messageController.text.trim(),
                  );
                  _messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null && mounted) {
      context.read<ChatDetailsCubit>().sendFileMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        file: File(pickedFile.path),
        type: MessageType.image,
      );
    }
  }
}
