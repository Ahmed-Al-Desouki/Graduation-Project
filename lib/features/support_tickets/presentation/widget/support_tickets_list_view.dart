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

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == tickets.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        return SupportTicketCard(ticket: tickets[index]);
      }, childCount: hasNextPage ? tickets.length + 1 : tickets.length),
    );
  }
}
