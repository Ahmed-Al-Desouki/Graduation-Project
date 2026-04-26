import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';

class SendTicketMessageUseCase {
  final TicketRepository repository;
  SendTicketMessageUseCase(this.repository);

  Future<Either<Failure, TicketMessageEntity>> call({
    required String ticketId,
    required String message,
  }) {
    return repository.sendTicketMessage(ticketId: ticketId, message: message);
  }
}
