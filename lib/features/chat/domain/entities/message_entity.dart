// class MessageEntity {
//   final String id;
//   final String text;
//   final DateTime time;
//   final String senderId;
//   final bool isMe; // لتحديد مكان الفقاعة (يمين أو يسار)

//   MessageEntity({
//     required this.id,
//     required this.text,
//     required this.time,
//     required this.senderId,
//     required this.isMe,
//   });
// }

class MessageEntity {
  final String messageId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type; // (text, image, pdf)
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
