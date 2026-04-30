import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';

class UploadChatFileUseCase {
  final ChatRepository repository;
  UploadChatFileUseCase(this.repository);
  Future<Either<Failure, String>> call(File file, String chatId) =>
      repository.uploadChatFile(file, chatId);
}
