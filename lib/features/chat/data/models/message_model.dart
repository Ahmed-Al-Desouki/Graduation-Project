import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.messageId,
    required super.senderId,
    required super.text,
    required super.timestamp,
    required super.type,
    super.fileUrl,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> json, String id) {
    return MessageModel(
      messageId: id,
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.byName(json['type'] ?? 'text'),
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type.name,
      'fileUrl': fileUrl,
    };
  }
}
