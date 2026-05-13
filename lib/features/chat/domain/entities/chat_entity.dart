class ChatEntity {
  final String chatId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isActive;
  final int unreadCount;
  final DateTime? lastReadTimestamp;

  ChatEntity({
    required this.chatId,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    this.lastMessage,
    this.lastMessageTime,
    required this.isActive,
    this.unreadCount = 0,
    this.lastReadTimestamp,
  });
}
