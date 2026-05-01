import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/mark_as_read_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/send_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/upload_chat_file_use_case.dart';
import 'package:meta/meta.dart';

part 'chat_details_state.dart';

class ChatDetailsCubit extends Cubit<ChatDetailsState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final UploadChatFileUseCase uploadChatFileUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  StreamSubscription? _messagesSub;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? _roomSub; // 🚀 استريم جديد للغرفة
  final String currentUserId =
      getIt<SessionManager>().userId; // ✅ معرف المستخدم الحالي
  String? _recipientId; //

  ChatDetailsCubit(
    this.getMessagesUseCase,
    this.sendMessageUseCase,
    this.uploadChatFileUseCase,
    this.markAsReadUseCase,
  ) : super(ChatDetailsInitial());

  // void listenToMessages(String chatId) {
  //   emit(ChatDetailsLoading());
  //   _messagesSubscription?.cancel();

  //   _messagesSubscription = getMessagesUseCase(chatId).listen((messages) {
  //     emit(ChatDetailsSuccess(messages));
  //   }, onError: (error) => emit(ChatDetailsFailure(error.toString())));
  // }

  void listenToMessages(String chatId) {
    emit(ChatDetailsLoading());
    _markChatAsRead(chatId, currentUserId);

    // 1. مراقبة حالة الغرفة (Active/Closed + معرفة المستلم)
    _roomSub?.cancel();
    _roomSub = firestore.collection('chats').doc(chatId).snapshots().listen((
      doc,
    ) {
      if (doc.exists) {
        final data = doc.data();
        final isActive = data?['isActive'] ?? true;
        final docId = data?['doctorId'].toString();
        final patId = data?['patientId'].toString();
        _recipientId = (currentUserId == docId) ? patId : docId;

        if (state is ChatDetailsSuccess) {
          emit((state as ChatDetailsSuccess).copyWith(isActive: isActive));
        } else {
          emit(ChatDetailsSuccess(messages: [], isActive: isActive));
        }
      }
    });

    // 2. مراقبة الرسائل (كما هي)
    _messagesSub?.cancel();
    _messagesSub = getMessagesUseCase(chatId).listen((messages) {
      if (messages.isNotEmpty) {
        final lastMessage =
            messages.first; // أول رسالة في اللستة هي الأحدث زمنياً

        if (lastMessage.senderId != currentUserId) {
          // لو الرسالة الأخيرة مش بتاعتي، يبقى أنا "قريتها" حالاً لأني فاتح الشات
          _markChatAsRead(chatId, currentUserId);
        }
      }
      if (state is ChatDetailsSuccess) {
        emit((state as ChatDetailsSuccess).copyWith(messages: messages));
      } else {
        emit(ChatDetailsSuccess(messages: messages));
      }
    });
  }

  Future<void> _markChatAsRead(String chatId, String userId) async {
    await markAsReadUseCase(chatId, userId);
  }

  // Future<void> sendNewMessage({
  //   required String chatId,
  //   required String senderId,
  //   required String text,
  // }) async {
  //   // 💡 هنا مش محتاج تضيف للمجموعة محلياً لأن الـ Stream
  //   // هيلقط التغيير من الفايربيز فوراً ويحدث الـ UI

  //   final message = MessageEntity(
  //     messageId: '', // الفايربيز هيكريه
  //     senderId: senderId,
  //     text: text,
  //     timestamp: DateTime.now(),
  //     type: MessageType.text,
  //   );

  //   final result = await sendMessageUseCase(chatId, message);

  //   result.fold(
  //     (failure) => emit(ChatDetailsFailure(failure.errmessage)),
  //     (_) => null, // النجاح سيظهر تلقائياً عبر الـ Stream
  //   );
  // }

  Future<void> sendNewMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (_recipientId == null) return; // حماية لو الداتا لسه مجتش

    final message = MessageEntity(
      messageId: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    // 💡 بنبعت الـ recipientId للـ UseCase عشان يزود عنده الـ Unread
    final result = await sendMessageUseCase(chatId, message, _recipientId!);

    result.fold(
      (failure) => emit(ChatDetailsFailure(failure.errmessage)),
      (_) => null,
    );
  }

  // ميثود رفع وإرسال ملف
  Future<void> sendFileMessage({
    required String chatId,
    required String senderId,
    required File file,
    required MessageType type,
  }) async {
    // 1. نطلع حالة الرفع عشان الـ UI يظهر Loading Spinner مثلاً
    emit(ChatDetailsUploading());

    final result = await uploadChatFileUseCase(file, chatId);

    result.fold((failure) => emit(ChatDetailsFailure(failure.errmessage)), (
      imageUrl,
    ) async {
      // 2. بعد ما الرفع يخلص وناخد الـ URL نبعت الرسالة كـ Document في Firestore
      final message = MessageEntity(
        messageId: '',
        senderId: senderId,
        text: type == MessageType.image ? '📷 صورة' : '📄 ملف PDF',
        timestamp: DateTime.now(),
        type: type,
        fileUrl: imageUrl,
      );

      await sendMessageUseCase(chatId, message, _recipientId!);
      // مش محتاجين Emit هنا لأن الـ Stream هيلقط الرسالة الجديدة لوحده
    });
  }

  // ميزة الدكتور: قفل أو فتح الشات
  Future<void> toggleChatStatus(String chatId, bool status) async {
    await firestore.collection('chats').doc(chatId).update({
      'isActive': status,
    });
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _roomSub?.cancel();
    return super.close();
  }
}
