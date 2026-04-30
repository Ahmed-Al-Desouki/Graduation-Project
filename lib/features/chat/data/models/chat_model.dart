// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';

// class ChatModel extends ChatEntity {
//   ChatModel({
//     required super.chatId,
//     required super.doctorId,
//     required super.patientId,
//     required super.doctorName,
//     required super.patientName,
//     super.lastMessage,
//     super.lastMessageTime,
//     required super.isActive,
//     super.unreadCount,
//     super.lastReadTimestamp,
//   });

//   factory ChatModel.fromFirestore(Map<String, dynamic> json, String id) {
//     final unreadMap = json['unreadCounts'] as Map<String, dynamic>? ?? {};
//   final timestampsMap = json['lastReadTimestamps'] as Map<String, dynamic>? ?? {};
//     return ChatModel(
//       chatId: id,
//       doctorId: json['doctorId'] ?? '',
//       patientId: json['patientId'] ?? '',
//       doctorName: json['doctorName'] ?? '',
//       patientName: json['patientName'] ?? '',
//       lastMessage: json['lastMessage'],
//       lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
//       isActive: json['isActive'] ?? true,
// unreadCount: unreadMap[currentUserId] ?? 0,
//     lastReadTimestamp: (timestampsMap[currentUserId] as Timestamp?)?.toDate(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'doctorId': doctorId,
//       'patientId': patientId,
//       'doctorName': doctorName,
//       'patientName': patientName,
//       'lastMessage': lastMessage,
//       'lastMessageTime': lastMessageTime,
//       'isActive': isActive,
//       'unreadCount': unreadCount,
//       'lastReadTimestamp': lastReadTimestamp,
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  ChatModel({
    required super.chatId,
    required super.doctorId,
    required super.patientId,
    required super.doctorName,
    required super.patientName,
    super.lastMessage,
    super.lastMessageTime,
    required super.isActive,
    super.unreadCount,
    super.lastReadTimestamp,
  });

  // ✅ عدلنا الـ factory عشان يستقبل الـ currentUserId
  factory ChatModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
    String currentUserId,
  ) {
    final unreadMap = json['unreadCounts'] as Map<String, dynamic>? ?? {};
    final timestampsMap =
        json['lastReadTimestamps'] as Map<String, dynamic>? ?? {};

    return ChatModel(
      chatId: id,
      doctorId: json['doctorId'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      patientName: json['patientName'] ?? '',
      lastMessage: json['lastMessage'],
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate(),
      isActive: json['isActive'] ?? true,
      // 🎯 بنحدد العداد والوقت الخاص بالمستخدم اللي فاتح الأبلكيشن بس
      unreadCount: unreadMap[currentUserId] ?? 0,
      lastReadTimestamp: (timestampsMap[currentUserId] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isActive': isActive,
      'unreadCounts': {},
      'lastReadTimestamps': {},
      // ملاحظة: الـ unreadCounts بتدار في الـ RemoteDataSource عبر الـ FieldValue
    };
  }
}
