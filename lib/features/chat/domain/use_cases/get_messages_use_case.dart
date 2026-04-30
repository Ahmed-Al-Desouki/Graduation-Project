import '../entities/message_entity.dart';
import '../repositories/i_chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);
  Stream<List<MessageEntity>> call(String chatId) =>
      repository.getMessages(chatId);
}
