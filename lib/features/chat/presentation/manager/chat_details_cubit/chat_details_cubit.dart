import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/chat/domain/entities/message_entity.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_messages_use_case.dart';
import 'package:graduation_project/features/chat/domain/use_cases/send_messages_use_case.dart';
import 'package:meta/meta.dart';

part 'chat_details_state.dart';

class ChatDetailsCubit extends Cubit<ChatDetailsState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  List<MessageEntity> _messages = [];

  ChatDetailsCubit(this.getMessagesUseCase, this.sendMessageUseCase)
    : super(ChatDetailsInitial());

  Future<void> fetchMessages(String chatId) async {
    emit(ChatDetailsLoading());
    final result = await getMessagesUseCase(chatId);
    result.fold((failure) => emit(ChatDetailsFailure(failure.errmessage)), (
      messages,
    ) {
      _messages = messages;
      emit(ChatDetailsSuccess(List.from(_messages)));
    });
  }

  Future<void> sendNewMessage(String chatId, String text) async {
    // إضافة الرسالة محلياً فوراً ليشعر المستخدم بالسرعة
    final newMessage = MessageEntity(
      id: DateTime.now().toString(),
      text: text,
      time: DateTime.now(),
      senderId: "me",
      isMe: true,
    );
    _messages.add(newMessage);
    emit(ChatDetailsSuccess(List.of(_messages)));

    // إرسالها للـ Repo (الذي هو حالياً Mock)
    await sendMessageUseCase(chatId, text);
  }
}
