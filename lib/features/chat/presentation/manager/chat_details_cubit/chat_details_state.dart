part of 'chat_details_cubit.dart';

@immutable
sealed class ChatDetailsState {}

final class ChatDetailsInitial extends ChatDetailsState {}

class ChatDetailsLoading extends ChatDetailsState {}

class ChatDetailsFailure extends ChatDetailsState {
  final String errMessage;
  ChatDetailsFailure(this.errMessage);
}

class ChatDetailsSuccess extends ChatDetailsState {
  final List<MessageEntity> messages;
  ChatDetailsSuccess(this.messages);
}
