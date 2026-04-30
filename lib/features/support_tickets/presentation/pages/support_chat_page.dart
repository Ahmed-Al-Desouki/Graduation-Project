import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/ticket_chat_cubit/ticket_chat_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/chat_bottom_bar.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/chat_messages_list.dart';

class SupportChatPage extends StatefulWidget {
  final String ticketId;
  final String? initialStatus;
  const SupportChatPage({
    super.key,
    required this.ticketId,
    this.initialStatus,
  });

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              getIt<TicketChatCubit>()..fetchMessages(
                widget.ticketId,
                initialStatus: widget.initialStatus,
              ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: BlocBuilder<TicketChatCubit, TicketChatState>(
            buildWhen: (previous, current) => current is TicketChatSuccess,
            builder: (context, state) {
              String title = "Ticket #${widget.ticketId.substring(0, 5)}";
              String currentStatus = "Loading...";

              if (state is TicketChatSuccess) {
                currentStatus = state.newStatus ?? "Open";
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "TKT-${widget.ticketId.substring(0, 5)} • $currentStatus",
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(currentStatus),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        body: Column(
          children: [
            const Expanded(child: ChatMessagesList()),

            BlocBuilder<TicketChatCubit, TicketChatState>(
              builder: (context, state) {
                String currentStatus = "Open";
                if (state is TicketChatSuccess) {
                  currentStatus = state.newStatus ?? "Open";
                }

                if (currentStatus == "Closed" || currentStatus == "Resolved") {
                  return _buildClosedBanner(currentStatus);
                }

                return ChatBottomBar(ticketId: widget.ticketId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.green;
      case "InProgress":
        return Colors.blue;
      case "Resolved":
      case "Closed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildClosedBanner(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            "this ticket is closed now ($status)",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
