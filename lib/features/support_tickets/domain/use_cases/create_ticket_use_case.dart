import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';

class CreateTicketUseCase {
  final TicketRepository repository;
  CreateTicketUseCase(this.repository);

  Future<Either<Failure, TicketEntity>> call({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) {
    return repository.createTicket(
      title: title,
      description: description,
      category: category,
      priority: priority,
    );
  }
}
