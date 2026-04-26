// lib/features/support_tickets/domain/entities/support_tickets_paginated_entity.dart

import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';

class TicketsPaginatedEntity {
  final List<TicketEntity> tickets;
  final int totalCount;
  final bool hasNextPage;

  TicketsPaginatedEntity({
    required this.tickets,
    required this.totalCount,
    required this.hasNextPage,
  });
}
