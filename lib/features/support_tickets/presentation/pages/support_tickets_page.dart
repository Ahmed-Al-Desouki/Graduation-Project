import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/create_ticket_bottom_sheet.dart';
import '../manager/tickets_cubit/tickets_cubit.dart';
import '../widget/support_tickets_list_view.dart';
import '../widget/support_search_bar.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TicketsCubit>().fetchTickets(isRefresh: true);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<TicketsCubit>().fetchTickets();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Support Tickets",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final ticketsCubit = context.read<TicketsCubit>();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) => BlocProvider.value(
                  value: ticketsCubit,
                  child: const CreateTicketBottomSheet(),
                ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<TicketsCubit, TicketsState>(
        builder: (context, state) {
          final cubit = context.read<TicketsCubit>();

          log(
            " Current state is: $state | Tickets count: ${cubit.allTickets.length}",
          );

          if (state is TicketsLoading && cubit.allTickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketsFailure && cubit.allTickets.isEmpty) {
            return Center(child: Text(state.errorMessage));
          }

          return RefreshIndicator(
            onRefresh: () => cubit.fetchTickets(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SupportSearchBar(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SupportTicketsListView(
                    tickets: cubit.allTickets,
                    hasNextPage: cubit.hasNextPage,
                    isLoadingMore: state is TicketsLoading,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}
