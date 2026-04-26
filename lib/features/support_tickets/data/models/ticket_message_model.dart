import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';

class TicketMessageModel extends TicketMessageEntity {
  TicketMessageModel({
    required super.id,
    required super.content,
    required super.senderName,
    required super.isFromAdmin,
    required super.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    return TicketMessageModel(
      id: json['id'],
      content: json['content'],
      senderName: json['senderName'],
      isFromAdmin: json['isFromAdmin'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
