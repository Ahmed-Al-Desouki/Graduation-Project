part of 'ticket_chat_cubit.dart';

@immutable
sealed class TicketChatState {}

final class TicketChatInitial extends TicketChatState {}

final class TicketChatLoading extends TicketChatState {}

final class TicketChatSuccess extends TicketChatState {
  final List<TicketMessageEntity> messages;
  final String? newStatus;

  TicketChatSuccess(this.messages, {this.newStatus});
}

final class TicketChatFailure extends TicketChatState {
  final String errorMessage;
  TicketChatFailure(this.errorMessage);
}

final class TicketChatSendFailure extends TicketChatState {
  final String errorMessage;
  TicketChatSendFailure(this.errorMessage);
}
