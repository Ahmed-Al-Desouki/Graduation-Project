import 'package:graduation_project/features/support_tickets/data/models/ticket_model.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/support_tickets_paginated_entity.dart';

class TicketsPaginatedModel extends TicketsPaginatedEntity {
  TicketsPaginatedModel({
    required super.tickets,
    required super.totalCount,
    required super.hasNextPage,
  });

  factory TicketsPaginatedModel.fromJson(Map<String, dynamic> json) {
    var ticketsList =
        (json['tickets'] as List? ?? [])
            .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
            .where((ticket) => ticket.id != "error")
            .toList();

    return TicketsPaginatedModel(
      tickets: ticketsList,
      totalCount: json['totalCount'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
