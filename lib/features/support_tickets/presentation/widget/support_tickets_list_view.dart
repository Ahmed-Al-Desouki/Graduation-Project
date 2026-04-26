// // widgets/support_tickets_list_view.dart
// import 'package:admin_dashboard_graduation_project/features/support_tickets/domain/entities/support_ticket_entity.dart';
// import 'package:admin_dashboard_graduation_project/features/support_tickets/presentation/widget/support_ticket_card.dart';
// import 'package:flutter/material.dart';

// class SupportTicketsListView extends StatelessWidget {
//   final List<SupportTicketEntity> tickets;

//   const SupportTicketsListView({super.key, required this.tickets});

//   @override
//   Widget build(BuildContext context) {
//     if (tickets.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 50),
//         child: Center(
//           child: Column(
//             children: [
//               Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
//               SizedBox(height: 8),
//               Text("No tickets found", style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: tickets.length,
//       itemBuilder: (context, index) {
//         // هنا هننادي الـ Card اللي هنعمله الحتة الجاية
//         return SupportTicketCard(ticket: tickets[index]);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/support_ticket_card.dart';

class SupportTicketsListView extends StatelessWidget {
  final List<TicketEntity> tickets;
  final bool hasNextPage;
  final bool isLoadingMore;

  const SupportTicketsListView({
    super.key,
    required this.tickets,
    required this.hasNextPage,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("لا توجد تذاكر حالياً")),
      );
    }

    // return SliverList(
    //   delegate: SliverChildBuilderDelegate((context, index) {
    //     if (index >= tickets.length) {
    //       // مؤشر تحميل عند الوصول للنهاية
    //       return const Padding(
    //         padding: EdgeInsets.symmetric(vertical: 16),
    //         child: Center(child: CircularProgressIndicator()),
    //       );
    //     }
    //     return SupportTicketCard(ticket: tickets[index]);
    //   }, childCount: hasNextPage ? tickets.length + 1 : tickets.length),
    // );
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // لو وصلنا للـ Item رقم (طول الليستة) ومعانا صفحة تانية، اظهر لودر
          if (index == tickets.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return SupportTicketCard(ticket: tickets[index]);
        },
        // لو في صفحة تانية زودنا واحد للـ Loader
        childCount: hasNextPage ? tickets.length + 1 : tickets.length,
      ),
    );
  }
}
