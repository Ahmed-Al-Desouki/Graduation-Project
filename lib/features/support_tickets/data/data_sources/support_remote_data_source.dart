import 'dart:developer';

import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/support_tickets/data/models/messages_paginated_model.dart';
import 'package:graduation_project/features/support_tickets/data/models/ticket_message_model.dart';
import 'package:graduation_project/features/support_tickets/data/models/ticket_model.dart';
import 'package:graduation_project/features/support_tickets/data/models/tickets_paginated_model.dart';

abstract class TicketRemoteDataSource {
  Future<TicketsPaginatedModel> getTickets({Map<String, dynamic>? query});
  Future<TicketModel> createTicket(Map<String, dynamic> body);
  Future<MessagesPaginatedModel> getMessages(
    String ticketId, {
    Map<String, dynamic>? query,
  });
  Future<TicketMessageModel> sendMessage(String ticketId, String message);
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final ApiService apiService;

  TicketRemoteDataSourceImpl(this.apiService);

  @override
  Future<TicketsPaginatedModel> getTickets({
    Map<String, dynamic>? query,
  }) async {
    final data = await apiService.get('tickets', queryParameters: query);
    log("🔍 Raw JSON from Server: $data");
    return TicketsPaginatedModel.fromJson(data);
  }

  @override
  Future<TicketModel> createTicket(Map<String, dynamic> body) async {
    final data = await apiService.post('tickets', body);
    return TicketModel.fromJson(data);
  }

  @override
  Future<MessagesPaginatedModel> getMessages(
    String ticketId, {
    Map<String, dynamic>? query,
  }) async {
    final data = await apiService.get(
      'tickets/$ticketId/messages',
      queryParameters: query,
    );
    return MessagesPaginatedModel.fromJson(data);
  }

  @override
  Future<TicketMessageModel> sendMessage(
    String ticketId,
    String message,
  ) async {
    final data = await apiService.post('tickets/$ticketId/messages', {
      'ticketId': ticketId,
      'message': message,
    });
    return TicketMessageModel.fromJson(data);
  }
}
