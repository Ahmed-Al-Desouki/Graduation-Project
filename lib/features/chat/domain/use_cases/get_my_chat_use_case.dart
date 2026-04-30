import '../entities/chat_entity.dart';
import '../repositories/i_chat_repository.dart';

class GetMyChatsUseCase {
  final ChatRepository repository;
  GetMyChatsUseCase(this.repository);
  Stream<List<ChatEntity>> call(String userId, bool isDoctor) =>
      repository.getMyChats(userId, isDoctor);
}
