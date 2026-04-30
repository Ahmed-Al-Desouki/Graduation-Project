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
  final bool isActive; // 🚀 دي اللي هتحل الأيرور

  ChatDetailsSuccess({required this.messages, this.isActive = true});

  // ميثود مهمة جداً عشان نحدث جزء من الستيت ونحافظ على الباقي
  ChatDetailsSuccess copyWith({List<MessageEntity>? messages, bool? isActive}) {
    return ChatDetailsSuccess(
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }
}
