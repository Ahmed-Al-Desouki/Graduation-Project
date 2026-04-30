part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatFailure extends ChatState {
  final String errMessage;
  ChatFailure(this.errMessage);
}

class ChatSuccess extends ChatState {
  final List<ChatEntity> chats; // القائمة التي ستظهر في الـ UI
  ChatSuccess(this.chats);
}
