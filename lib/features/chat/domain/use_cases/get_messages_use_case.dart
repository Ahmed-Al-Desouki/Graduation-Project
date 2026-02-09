// lib/features/chat/domain/use_cases/get_messages_use_case.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/i_chat_repository.dart';

class GetMessagesUseCase {
  final IChatRepository repository;
  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String chatId) async {
    return await repository.getMessages(chatId);
  }
}
