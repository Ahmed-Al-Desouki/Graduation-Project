import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/ticket_chat_cubit/ticket_chat_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/chat_bottom_bar.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/chat_messages_list.dart';

// class SupportChatPage extends StatelessWidget {
//   final TicketEntity ticket; // استخدمنا الـ Entity اللي عملناها للموبايل

//   const SupportChatPage({super.key, required this.ticket});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<TicketChatCubit>()..fetchMessages(ticket.id),
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: false,
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 ticket.title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "TKT-${ticket.id.substring(0, 5)} • ${ticket.status}",
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),

//         // lib/features/support_tickets/presentation/pages/support_chat_page.dart
//         body: Column(
//           children: [
//             const Expanded(child: ChatMessagesList()),

//             // 🚀 الـ BlocBuilder هنا هو اللي هيتحكم في ظهور الـ TextField
//             BlocBuilder<TicketChatCubit, TicketChatState>(
//               builder: (context, state) {
//                 String currentStatus = ticket.status;

//                 if (state is TicketChatSuccess) {
//                   currentStatus = state.newStatus ?? currentStatus;
//                 }

//                 // لو الحالة مقفولة أو محلولة، شيل الـ Input Bar
//                 if (currentStatus == "Closed" || currentStatus == "Resolved") {
//                   return Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     color: Colors.grey.shade100,
//                     child: Column(
//                       children: [
//                         Icon(Icons.lock_outline, color: Colors.grey.shade600),
//                         const SizedBox(height: 8),
//                         Text(
//                           "هذه التذكرة مغلقة حالياً $currentStatus",
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // لو لسه مفتوحة، اظهر الـ Bottom Bar عادي
//                 return ChatBottomBar(ticketId: ticket.id);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SupportChatPage extends StatelessWidget {
  final TicketEntity ticket;

  const SupportChatPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TicketChatCubit>()..fetchMessages(ticket.id),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: BlocBuilder<TicketChatCubit, TicketChatState>(
            // بنستخدم buildWhen عشان الـ AppBar ميعملش ريبيلد مع كل رسالة، بس لما الحالة تتغير
            buildWhen: (previous, current) => current is TicketChatSuccess,
            builder: (context, state) {
              String currentStatus = ticket.status;
              if (state is TicketChatSuccess) {
                currentStatus = state.newStatus ?? currentStatus;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "TKT-${ticket.id.substring(0, 5)} • $currentStatus",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          currentStatus == "Open"
                              ? Colors.green
                              : (currentStatus == "InProgress"
                                  ? Colors.blue
                                  : Colors.red), // حتة شياكة
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

            // الـ BlocBuilder الخاص بالـ Input Bar
            BlocBuilder<TicketChatCubit, TicketChatState>(
              builder: (context, state) {
                String currentStatus = ticket.status;

                if (state is TicketChatSuccess) {
                  currentStatus = state.newStatus ?? currentStatus;
                }

                if (currentStatus == "Closed" || currentStatus == "Resolved") {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text(
                          "هذه التذكرة مغلقة حالياً ($currentStatus)",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ChatBottomBar(ticketId: ticket.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
