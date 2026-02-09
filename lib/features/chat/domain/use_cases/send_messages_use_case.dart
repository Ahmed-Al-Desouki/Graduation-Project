// lib/features/chat/domain/use_cases/send_message_use_case.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_chat_repository.dart';

class SendMessageUseCase {
  final IChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId, String message) async {
    return await repository.sendMessage(chatId, message);
  }
}
