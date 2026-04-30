import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';

class CreateChatRoomUseCase {
  final ChatRepository repository;
  CreateChatRoomUseCase(this.repository);

  Future<Either<Failure, void>> call(ChatEntity chatEntity) async {
    // هنضيف الميثود دي في الـ Repository الأول طبعاً
    return await repository.createChatRoom(chatEntity);
  }
}
