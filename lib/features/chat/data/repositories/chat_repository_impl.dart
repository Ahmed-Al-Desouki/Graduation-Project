import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/chat/data/models/chat_model.dart';
import 'package:graduation_project/features/chat/data/models/message_model.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import 'package:graduation_project/features/chat/domain/repositories/i_chat_repository.dart';
import '../data_sources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<Either<Failure, void>> sendMessage(
    String chatId,
    MessageEntity message,
    String recipientId,
  ) async {
    try {
      final model = MessageModel(
        messageId: message.messageId,
        senderId: message.senderId,
        text: message.text,
        timestamp: message.timestamp,
        type: message.type,
        fileUrl: message.fileUrl,
      );
      await remoteDataSource.sendMessage(chatId, model, recipientId);
      return right(null);
    } on FirebaseException catch (e) {
      // استخدمنا الـ FirebaseFailure اللي زودناه
      return left(FirebaseFailure(e.message ?? 'Firebase Error occurred'));
    } catch (e) {
      return left(FirebaseFailure('An unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadChatFile(
    File file,
    String chatId,
  ) async {
    try {
      final url = await remoteDataSource.uploadChatFile(file, chatId);
      return right(url);
    } catch (e) {
      return left(FirebaseFailure('Failed to upload file'));
    }
  }

  @override
  Stream<List<ChatEntity>> getMyChats(String userId, bool isDoctor) {
    return remoteDataSource.getMyChats(userId, isDoctor);
  }

  @override
  Future<Either<Failure, void>> createChatRoom(ChatEntity chatEntity) async {
    try {
      final chatModel = ChatModel(
        chatId: chatEntity.chatId,
        doctorId: chatEntity.doctorId,
        patientId: chatEntity.patientId,
        doctorName: chatEntity.doctorName,
        patientName: chatEntity.patientName,
        lastMessage: chatEntity.lastMessage,
        lastMessageTime: chatEntity.lastMessageTime,
        isActive: chatEntity.isActive,
      );
      await remoteDataSource.createChatRoom(chatModel);
      return right(null);
    } catch (e) {
      return left(FirebaseFailure('Failed to create chat room'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String chatId, String userId) async {
    try {
      await remoteDataSource.markAsRead(chatId, userId);
      return right(null);
    } catch (e) {
      return left(FirebaseFailure("فشل تحديث حالة القراءة"));
    }
  }
}
