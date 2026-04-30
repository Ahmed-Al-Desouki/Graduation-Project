import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/color_helper.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/app_padge.dart';
import 'package:intl/intl.dart';

class SupportTicketCard extends StatelessWidget {
  final TicketEntity ticket;

  const SupportTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          context.push(
            '/tickets/ticket-chat',
            extra: {'id': ticket.id, 'status': ticket.status},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildLeftHeader(), _buildRightHeader()],
              ),
              const SizedBox(height: 12),

              Text(
                ticket.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftHeader() {
    return Row(
      children: [
        Text(
          "TKT-${ticket.id.substring(0, 4).toUpperCase()}",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 8),
        AppBadge(
          label: ticket.priority,
          color: getPriorityColor(ticket.priority),
        ),
      ],
    );
  }

  Widget _buildRightHeader() {
    return Row(
      children: [
        AppBadge(label: ticket.status, color: getStatusColor(ticket.status)),
        const SizedBox(width: 8),
        _CategoryBadge(category: ticket.category),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(Icons.category_outlined, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          ticket.category,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Spacer(),
        const Icon(Icons.message_outlined, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          "${ticket.messageCount ?? 0}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Text(
          DateFormat('dd/MM/yy').format(ticket.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'urgent':
        color = const Color(0xFFEF4444);
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 12, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
      ),
    );
  }
}
