import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/ticket_chat_cubit/ticket_chat_cubit.dart';

class ChatBottomBar extends StatefulWidget {
  final String ticketId;
  const ChatBottomBar({super.key, required this.ticketId});

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _isTextEmpty = _controller.text.trim().isEmpty);
    });
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<TicketChatCubit>().sendMessage(
        widget.ticketId,
        _controller.text.trim(),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Type your response...",
                  hintStyle: const TextStyle(fontSize: 14),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor:
                  _isTextEmpty ? Colors.grey.shade300 : const Color(0xFF0D9488),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isTextEmpty ? null : _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
