import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/support_tickets_paginated_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';

class GetMyTicketsUseCase {
  final TicketRepository repository;
  GetMyTicketsUseCase(this.repository);

  Future<Either<Failure, TicketsPaginatedEntity>> call({
    int page = 1,
    String? status,
    String? priority,
    String? category,
    DateTimeRange? dateRange,
  }) {
    return repository.getMyTickets(
      page: page,
      status: status,
      priority: priority,
      category: category,
      dateRange: dateRange,
    );
  }
}
