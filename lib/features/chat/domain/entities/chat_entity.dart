// class ChatEntity {
//   final String chatId; // هو نفسه الـ Appointment ID
//   final String doctorId;
//   final String patientId;
//   final String doctorName;
//   final String patientName;
//   final String? lastMessage;
//   final DateTime? lastMessageTime;
//   final bool isActive; // هيتم التحكم فيها بناءً على وقت الحجز
//   final int unreadCount;
//   final DateTime? lastReadTimestamp;

//   ChatEntity({
//     required this.chatId,
//     required this.doctorId,
//     required this.patientId,
//     required this.doctorName,
//     required this.patientName,
//     this.lastMessage,
//     this.lastMessageTime,
//     required this.isActive,
//     this.unreadCount = 0,
//     this.lastReadTimestamp,
//   });
// }

class ChatEntity {
  final String chatId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isActive;
  final int unreadCount; // 🚀
  final DateTime? lastReadTimestamp; // 🚀

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
