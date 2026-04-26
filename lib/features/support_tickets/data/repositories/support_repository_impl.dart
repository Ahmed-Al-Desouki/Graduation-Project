// import '../../domain/entities/ticket_message_entity.dart';
// import '../../domain/repositories/support_repository.dart';
// import '../data_sources/support_remote_data_source.dart';

// class SupportRepositoryImpl implements SupportRepository {
//   final SupportRemoteDataSource remoteDataSource;
//   SupportRepositoryImpl(this.remoteDataSource);

//   @override
//   Future<Either<Failure, SupportTicketsPaginatedEntity>> getTickets({
//     int? page,
//     int? pageSize,
//     String? status,
//     String? priority,
//     String? category,
//     int? userId,
//     String? searchTerm,
//     String? fromDate,
//     String? toDate,
//     String? sortBy,
//     bool descending = true,
//   }) async {
//     try {
//       final paginatedData = await remoteDataSource.getTickets(
//         page: page,
//         pageSize: pageSize,
//         status: status,
//         priority: priority,
//         category: category,
//         userId: userId,
//         searchTerm: searchTerm,
//         fromDate: fromDate,
//         toDate: toDate,
//         sortBy: sortBy,
//         descending: descending,
//       );
//       return Right(paginatedData);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, List<TicketMessageEntity>>> getTicketMessages(
//     String ticketId,
//   ) async {
//     try {
//       final messages = await remoteDataSource.getTicketMessages(ticketId);
//       return Right(messages);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, TicketMessageEntity>> respondToTicket(
//     String ticketId,
//     String message,
//   ) async {
//     try {
//       final response = await remoteDataSource.respondToTicket(
//         ticketId,
//         message,
//       );
//       return Right(response);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, String>> updateTicketStatus(
//     String ticketId,
//     String status,
//   ) async {
//     try {
//       await remoteDataSource.updateTicketStatus(ticketId, status);
//       return const Right("Status updated successfully");
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, String>> updateTicketPriority(
//     String ticketId,
//     String priority,
//   ) async {
//     try {
//       await remoteDataSource.updateTicketPriority(ticketId, priority);
//       return const Right("Priority updated successfully");
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   @override
//   Future<Either<Failure, SupportStatsEntity>> getTicketsStatistics() async {
//     try {
//       final stats = await remoteDataSource.getTicketsStatistics();
//       return Right(stats);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
// }

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/features/support_tickets/data/data_sources/support_remote_data_source.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/support_tickets_paginated_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/repositories/support_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_message_entity.dart';
import '../../domain/entities/messages_paginated_entity.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TicketsPaginatedEntity>> getMyTickets({
    int page = 1,
    int pageSize = 10,
    String? status,
    String? category,
    String? priority,
    DateTimeRange? dateRange,
  }) async {
    try {
      final query = {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        if (priority != null) 'priority': priority,
        if (dateRange != null) 'fromDate': dateRange.start,
        if (dateRange != null) 'toDate': dateRange.end,
        'descending': true, // الديفولت بتاعنا زي ما شفنا في سواجر
      };

      final result = await remoteDataSource.getTickets(query: query);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final body = {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      };

      final result = await remoteDataSource.createTicket(body);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessagesPaginatedEntity>> getTicketMessages({
    required String ticketId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final query = {
        'page': page,
        'pageSize': pageSize,
        'sort': 'asc', // عشان الرسايل تظهر بالترتيب الزمني الصحيح
      };

      final result = await remoteDataSource.getMessages(ticketId, query: query);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TicketMessageEntity>> sendTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    try {
      final result = await remoteDataSource.sendMessage(ticketId, message);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
