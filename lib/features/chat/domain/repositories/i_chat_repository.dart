import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages(String chatId);
  Future<Either<Failure, void>> sendMessage(
    String chatId,
    MessageEntity message,
    String recipientId,
  );
  Future<Either<Failure, String>> uploadChatFile(File file, String chatId);
  Stream<List<ChatEntity>> getMyChats(String userId, bool isDoctor);
  Future<Either<Failure, void>> createChatRoom(ChatEntity chatEntity);
  Future<Either<Failure, void>> markAsRead(String chatId, String userId);
}
