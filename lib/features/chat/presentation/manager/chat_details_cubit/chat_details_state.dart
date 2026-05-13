part of 'chat_details_cubit.dart';

@immutable
sealed class ChatDetailsState {}

final class ChatDetailsInitial extends ChatDetailsState {}

class ChatDetailsLoading extends ChatDetailsState {}

class ChatDetailsUploading extends ChatDetailsState {}

class ChatDetailsFailure extends ChatDetailsState {
  final String errMessage;
  ChatDetailsFailure(this.errMessage);
}

class ChatDetailsSuccess extends ChatDetailsState {
  final List<MessageEntity> messages;
  final bool isActive;

  ChatDetailsSuccess({required this.messages, this.isActive = true});

  ChatDetailsSuccess copyWith({List<MessageEntity>? messages, bool? isActive}) {
    return ChatDetailsSuccess(
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }
}
