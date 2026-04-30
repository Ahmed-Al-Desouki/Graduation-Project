import 'dart:developer';

import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  TicketModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.status,
    required super.priority,
    required super.createdAt,
    super.messageCount,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    try {
      return TicketModel(
        id: json['id']?.toString() ?? "",

        title: json['title'] ?? "No Title",
        description: json['description'] ?? "",
        category: json['category'] ?? "Other",
        status: json['status'] ?? "Open",
        priority: json['priority'] ?? "Normal",

        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'].toString())
                : DateTime.now(),

        messageCount: json['messageCount'] ?? 0,
      );
    } catch (e) {
      log(" Error parsing individual ticket: $e");
      return TicketModel(
        id: "error",
        title: "Error loading ticket",
        description: "",
        category: "",
        status: "",
        priority: "",
        createdAt: DateTime.now(),
      );
    }
  }
}
