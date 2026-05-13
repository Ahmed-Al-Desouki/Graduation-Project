import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/support_filter_sheet.dart';

class SupportSearchBar extends StatelessWidget {
  const SupportSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [const SizedBox(width: 12), _buildFilterButton(context)],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final supportCubit = context.read<TicketsCubit>();

    return IconButton(
      icon: const Icon(Icons.tune, color: Colors.grey),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => BlocProvider.value(
                value: supportCubit,
                child: const SupportFilterSheet(),
              ),
        );
      },
    );
  }
}
