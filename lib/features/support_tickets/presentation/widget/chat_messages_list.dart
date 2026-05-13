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
            controller: _scrollController,
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
