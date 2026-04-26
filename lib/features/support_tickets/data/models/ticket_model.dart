import 'package:flutter/material.dart';
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

  // factory TicketModel.fromJson(Map<String, dynamic> json) {
  //   return TicketModel(
  //     id: json['id'].toString(),
  //     title: json['title'] ?? "No Title",
  //     description: json['description'] ?? "",
  //     category: json['category'],
  //     status: json['status'],
  //     priority: json['priority'],
  //     createdAt: DateTime.parse(json['createdAt']),
  //     messageCount: json['messageCount'] ?? 0,
  //   );
  // }
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    try {
      return TicketModel(
        // 1. نضمن إن الـ ID دايمًا String حتى لو جاي رقم أو GUID
        id: json['id']?.toString() ?? "",

        title: json['title'] ?? "No Title",
        description: json['description'] ?? "",
        category: json['category'] ?? "Other",
        status: json['status'] ?? "Open",
        priority: json['priority'] ?? "Normal",

        // 2. معالجة التاريخ بشكل آمن
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'].toString())
                : DateTime.now(),

        messageCount: json['messageCount'] ?? 0,
      );
    } catch (e) {
      // لو حصل مشكلة في تذكرة معينة، اطبع الأيرور ورجع تذكرة فاضية بدل ما يضرب الأبلكيشن كله
      debugPrint("❌ Error parsing individual ticket: $e");
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
