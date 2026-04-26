class TicketMessageEntity {
  final String id;
  final String content;
  final String senderName;
  final bool isFromAdmin;
  final DateTime createdAt;

  TicketMessageEntity({
    required this.id,
    required this.content,
    required this.senderName,
    required this.isFromAdmin,
    required this.createdAt,
  });
}
