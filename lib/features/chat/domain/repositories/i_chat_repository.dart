// lib/features/chat/domain/repositories/i_chat_repository.dart
import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_preview_entity.dart';

abstract class IChatRepository {
  Future<Either<Failure, List<ChatPreviewEntity>>> getChatPreviews();
  Future<Either<Failure, List<MessageEntity>>> getMessages(String chatId);
  Future<Either<Failure, void>> sendMessage(String chatId, String message);
}
