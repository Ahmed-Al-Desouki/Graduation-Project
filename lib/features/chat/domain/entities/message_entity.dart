class MessageEntity {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? fileUrl;

  MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.type,
    this.fileUrl,
  });
}

enum MessageType { text, image, pdf }
