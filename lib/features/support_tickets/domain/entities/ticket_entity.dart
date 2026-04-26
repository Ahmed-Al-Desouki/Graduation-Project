class TicketEntity {
  final String id; // تم التعديل لـ String
  final String title;
  final String description;
  final String category;
  final String status;
  final String priority;
  final DateTime createdAt;
  final int? messageCount;

  TicketEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.messageCount,
  });
}
