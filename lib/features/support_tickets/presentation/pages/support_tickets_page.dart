import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
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
    // نداء أول صفحة
    context.read<TicketsCubit>().fetchTickets(isRefresh: true);

    // إعداد الـ Listener للـ Pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // لو اليوزر وصل لـ 80% من طول القائمة، حمل الصفحة اللي بعدها
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<TicketsCubit>().fetchTickets();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // مهم جداً عشان الـ Memory Leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ❌ شيلنا الـ BlocProvider اللي كان هنا عشان أنت عامله في الـ GoRouter أصلاً
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "الدعم الفني",
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
          // استخدم الـ context الحالي اللي شايف الكيوبت بتاع الـ Router
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

          // 💡 للتأكد: اطبع عدد التذاكر هنا في الـ Debug Console
          debugPrint(
            "🎯 Current state is: $state | Tickets count: ${cubit.allTickets.length}",
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
