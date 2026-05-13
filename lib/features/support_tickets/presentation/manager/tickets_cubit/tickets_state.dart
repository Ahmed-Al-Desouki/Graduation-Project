part of 'tickets_cubit.dart';

@immutable
sealed class TicketsState {}

final class TicketsInitial extends TicketsState {}

final class TicketsLoading extends TicketsState {}

class TicketsSuccess extends TicketsState {
  final List<TicketEntity> tickets;
  final bool hasNextPage;
  final String? currentStatus;
  final String? currentPriority;
  final String? currentCategory;
  final DateTimeRange? currentDateRange;

  TicketsSuccess(
    this.tickets,
    this.hasNextPage, {
    this.currentStatus,
    this.currentPriority,
    this.currentCategory,
    this.currentDateRange,
  });
}

final class TicketsFailure extends TicketsState {
  final String errorMessage;
  TicketsFailure(this.errorMessage);
}
