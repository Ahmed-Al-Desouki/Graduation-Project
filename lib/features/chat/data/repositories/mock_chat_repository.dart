// // lib/features/chat/data/repositories/mock_chat_repository.dart
// import 'package:dartz/dartz.dart';
// import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
// import '../../../../core/errors/failures.dart';
// import '../../domain/entities/chat_preview_entity.dart';
// import '../../domain/repositories/i_chat_repository.dart';

// class MockChatRepository implements IChatRepository {
//   @override
//   Future<Either<Failure, List<ChatPreviewEntity>>> getChatPreviews() async {
//     // محاكاة تأخير الشبكة (2 ثانية)
//     await Future.delayed(const Duration(seconds: 2));

//     try {
//       final List<ChatPreviewEntity> mockData = [
//         ChatPreviewEntity(
//           id: "1",
//           receiverName: "Dr. Sarah Chen",
//           receiverImage: "https://randomuser.me/api/portraits/women/1.jpg",
//           lastMessage: "Your test results are ready for review.",
//           lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
//           unreadCount: 2,
//           isLastMessageFromMe: false, // هي اللي بعتت
//         ),
//         ChatPreviewEntity(
//           id: "2",
//           receiverName: "Dr. Michael Rodriguez",
//           receiverImage: "https://randomuser.me/api/portraits/men/2.jpg",
//           lastMessage: "Please continue with the prescribed meds.",
//           lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
//           unreadCount: 0,
//           isLastMessageFromMe: true, // أنا اللي بعت
//         ),
//         ChatPreviewEntity(
//           id: "3",
//           receiverName: "Dr. Emily Watson",
//           lastMessage: "Thank you for the update. See you Monday.",
//           lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
//           unreadCount: 1,
//           isLastMessageFromMe: false,
//         ),
//       ];

//       return Right(mockData);
//     } catch (e) {
//       return Left(ServerFailure("Failed to load chats from mock."));
//     }
//   }

//   @override
//   Future<Either<Failure, List<MessageEntity>>> getMessages(
//     String chatId,
//   ) async {
//     await Future.delayed(const Duration(seconds: 1)); // محاكاة تحميل
//     return Right([
//       MessageEntity(
//         id: "1",
//         text: "Hello Doctor",
//         time: DateTime.now().subtract(Duration(minutes: 10)),
//         senderId: "patient",
//         isMe: true,
//       ),
//       MessageEntity(
//         id: "2",
//         text: "Hi! How can I help you?",
//         time: DateTime.now().subtract(Duration(minutes: 5)),
//         senderId: "doctor",
//         isMe: false,
//       ),
//     ]);
//   }

//   @override
//   Future<Either<Failure, void>> sendMessage(
//     String chatId,
//     String message,
//   ) async {
//     await Future.delayed(const Duration(seconds: 1)); // محاكاة إرسال
//     return Right(null); // لا حاجة لبيانات عودة في هذا المثال
//   }
// }
