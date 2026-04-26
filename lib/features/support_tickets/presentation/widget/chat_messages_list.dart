// // widgets/chat_messages_list.dart
// import 'package:admin_dashboard_graduation_project/features/support_tickets/presentation/manager/support_chat_cubit/support_chat_cubit.dart';
// import 'package:admin_dashboard_graduation_project/features/support_tickets/presentation/widget/message_bubble.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatMessagesList extends StatelessWidget {
//   const ChatMessagesList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SupportChatCubit, SupportChatState>(
//       builder: (context, state) {
//         if (state is SupportChatLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state is SupportChatFailure) {
//           return Center(child: Text(state.errMessage));
//         }

//         if (state is SupportChatSuccess) {
//           final messages = state.messages;

//           if (messages.isEmpty) {
//             return const Center(
//               child: Text("No messages yet. Start the conversation!"),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             itemCount: messages.length,
//             itemBuilder: (context, index) {
//               return MessageBubble(message: messages[index]);
//             },
//           );
//         }

//         return const SizedBox();
//       },
//     );
//   }
// }

// lib/features/tickets/presentation/widget/chat_messages_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/ticket_chat_cubit/ticket_chat_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/message_bubble.dart';

class ChatMessagesList extends StatefulWidget {
  const ChatMessagesList({super.key});

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketChatCubit, TicketChatState>(
      listener: (context, state) {
        if (state is TicketChatSuccess) {
          // أول ما تيجي رسالة (سواء مني أو من SignalR) انزل تحت
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      },
      builder: (context, state) {
        if (state is TicketChatLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is TicketChatFailure)
          return Center(child: Text(state.errorMessage));

        if (state is TicketChatSuccess) {
          return ListView.builder(
            controller: _scrollController, // ربط السكرول
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: state.messages.length,
            itemBuilder:
                (context, index) =>
                    MessageBubble(message: state.messages[index]),
          );
        }
        return const SizedBox();
      },
    );
  }
}
