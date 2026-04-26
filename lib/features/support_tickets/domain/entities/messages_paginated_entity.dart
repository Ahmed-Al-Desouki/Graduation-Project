import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';

class MessagesPaginatedEntity {
  final List<TicketMessageEntity> messages;
  final int totalCount;
  final bool hasNextPage;

  MessagesPaginatedEntity({
    required this.messages,
    required this.totalCount,
    required this.hasNextPage,
  });
}
