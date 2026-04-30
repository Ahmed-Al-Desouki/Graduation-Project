import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';

class MarkAsReadUseCase {
  final ChatRepository repository;
  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId, String userId) async {
    return await repository.markAsRead(chatId, userId);
  }
}
