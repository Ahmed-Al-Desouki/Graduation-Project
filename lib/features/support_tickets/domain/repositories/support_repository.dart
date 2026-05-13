import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/messages_paginated_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/support_tickets_paginated_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';

abstract class TicketRepository {
  Future<Either<Failure, TicketsPaginatedEntity>> getMyTickets({
    int page = 1,
    int pageSize = 10,
    String? status,
    String? category,
    String? priority,
    DateTimeRange? dateRange,
  });

  Future<Either<Failure, TicketEntity>> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  });

  Future<Either<Failure, MessagesPaginatedEntity>> getTicketMessages({
    required String ticketId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, TicketMessageEntity>> sendTicketMessage({
    required String ticketId,
    required String message,
  });
}
