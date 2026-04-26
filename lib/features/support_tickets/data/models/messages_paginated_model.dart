import 'package:graduation_project/features/support_tickets/data/models/ticket_message_model.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/messages_paginated_entity.dart';

class MessagesPaginatedModel extends MessagesPaginatedEntity {
  MessagesPaginatedModel({
    required super.messages,
    required super.totalCount,
    required super.hasNextPage,
  });

  factory MessagesPaginatedModel.fromJson(Map<String, dynamic> json) {
    return MessagesPaginatedModel(
      messages:
          (json['messages'] as List)
              .map((e) => TicketMessageModel.fromJson(e))
              .toList(),
      totalCount: json['totalCount'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
