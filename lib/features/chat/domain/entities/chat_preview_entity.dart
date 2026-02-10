class ChatPreviewEntity {
  final String id;
  final String receiverName;
  final String? receiverImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isLastMessageFromMe;

  ChatPreviewEntity({
    required this.id,
    required this.receiverName,
    this.receiverImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isLastMessageFromMe,
  });
}
