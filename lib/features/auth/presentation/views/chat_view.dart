import 'package:flutter/material.dart';
import 'package:graduation_project/features/chat/presentation/views/messages_list_view.dart';

class ChatView extends StatelessWidget {
  final String userId;
  final bool isDoctor;

  const ChatView({super.key, required this.userId, required this.isDoctor});

  @override
  Widget build(BuildContext context) {
    return MessagesListView(currentUserId: userId, isDoctor: isDoctor);
  }
}
