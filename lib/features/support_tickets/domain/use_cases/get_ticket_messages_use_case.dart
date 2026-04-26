import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/messages_paginated_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';

class GetTicketMessagesUseCase {
  final TicketRepository repository;
  GetTicketMessagesUseCase(this.repository);

  Future<Either<Failure, MessagesPaginatedEntity>> call({
    required String ticketId,
    int page = 1,
  }) {
    return repository.getTicketMessages(ticketId: ticketId, page: page);
  }
}
