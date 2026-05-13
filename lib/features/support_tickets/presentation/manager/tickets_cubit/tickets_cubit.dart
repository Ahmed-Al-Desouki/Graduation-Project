import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/create_ticket_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/get_my_tickets_use_case.dart';
import 'package:meta/meta.dart';

part 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetMyTicketsUseCase getMyTicketsUseCase;
  final CreateTicketUseCase createTicketUseCase;

  String? status;
  String? priority;
  String? category;
  DateTimeRange? dateRange;
  TicketsCubit(this.getMyTicketsUseCase, this.createTicketUseCase)
    : super(TicketsInitial());

  List<TicketEntity> allTickets = [];
  int currentPage = 1;
  bool hasNextPage = true;

  Future<void> fetchTickets({
    bool isRefresh = false,
    String? status,
    String? priority,
    String? category,
    DateTimeRange? dateRange,
  }) async {
    if (isRefresh) {
      currentPage = 1;
      allTickets.clear();
      this.status = status == "All" ? null : status ?? this.status;
      this.priority = priority == "All" ? null : priority ?? this.priority;
      this.category = category == "All" ? null : category ?? this.category;
      this.dateRange = dateRange ?? this.dateRange;
    }

    if (!isRefresh && !hasNextPage) return;

    emit(TicketsLoading());

    final result = await getMyTicketsUseCase(
      page: currentPage,
      status: this.status,
      priority: this.priority,
      category: this.category,
      dateRange: this.dateRange,
    );

    result.fold((failure) => emit(TicketsFailure(failure.errmessage)), (
      paginatedEntity,
    ) {
      currentPage++;
      hasNextPage = paginatedEntity.hasNextPage;
      allTickets.addAll(paginatedEntity.tickets);

      emit(
        TicketsSuccess(
          List.from(allTickets),
          hasNextPage,
          currentStatus: this.status,
          currentPriority: this.priority,
          currentCategory: this.category,
          currentDateRange: this.dateRange,
        ),
      );
    });
  }

  void resetAllFilters() {
    status = null;
    priority = null;
    category = null;
    dateRange = null;
    fetchTickets(isRefresh: true);
  }

  Future<void> createNewTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    emit(TicketsLoading());
    final result = await createTicketUseCase(
      title: title,
      description: description,
      category: category,
      priority: priority,
    );

    result.fold((failure) => emit(TicketsFailure(failure.errmessage)), (
      ticketEntity,
    ) {
      fetchTickets(isRefresh: true);
    });
  }
}
