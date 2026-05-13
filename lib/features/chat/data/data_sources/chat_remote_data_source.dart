import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graduation_project/features/chat/data/models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(
    String chatId,
    MessageModel message,
    String recipientId,
  );
  Future<String> uploadChatFile(File file, String chatId);
  Stream<List<ChatModel>> getMyChats(String userId, bool isDoctor);
  Future<void> createChatRoom(ChatModel chatModel);
  Future<void> markAsRead(String chatId, String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  @override
  Stream<List<ChatModel>> getMyChats(String userId, bool isDoctor) {
    return _firestore
        .collection('chats')
        .where(isDoctor ? 'doctorId' : 'patientId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (doc) =>
                        ChatModel.fromFirestore(doc.data(), doc.id, userId),
                  )
                  .toList(),
        );
  }

  @override
  Future<void> sendMessage(
    String chatId,
    MessageModel message,
    String recipientId,
  ) async {
    final batch = _firestore.batch();
    final msgRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, message.toFirestore());

    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.$recipientId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  @override
  Future<String> uploadChatFile(File file, String chatId) async {
    var ref = _storage.ref().child(
      'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}',
    );
    var uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<void> createChatRoom(ChatModel chatModel) async {
    await _firestore
        .collection('chats')
        .doc(chatModel.chatId)
        .set(chatModel.toFirestore());
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$userId': 0,
      'lastReadTimestamps.$userId': FieldValue.serverTimestamp(),
    });
  }
}
