class MessageEntity {
  final String id;
  final String text;
  final DateTime time;
  final String senderId;
  final bool isMe; // لتحديد مكان الفقاعة (يمين أو يسار)

  MessageEntity({
    required this.id,
    required this.text,
    required this.time,
    required this.senderId,
    required this.isMe,
  });
}
