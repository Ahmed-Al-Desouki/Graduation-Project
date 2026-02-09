// lib/features/chat/domain/use_cases/get_chat_previews_use_case.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_preview_entity.dart';
import '../repositories/i_chat_repository.dart';

class GetChatPreviewsUseCase {
  final IChatRepository repository;

  GetChatPreviewsUseCase(this.repository);

  // استخدام call بيخلينا ننادي الـ Use Case كأنها دالة: useCase()
  Future<Either<Failure, List<ChatPreviewEntity>>> call() async {
    return await repository.getChatPreviews();
  }
}
