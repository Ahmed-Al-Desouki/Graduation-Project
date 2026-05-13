import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);
  Future<Either<Failure, void>> call(
    String chatId,
    MessageEntity msg,
    String recipientId,
  ) => repository.sendMessage(chatId, msg, recipientId);
}
