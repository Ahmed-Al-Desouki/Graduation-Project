// import 'package:admin_dashboard_graduation_project/features/support_tickets/presentation/manager/support_cubit/support_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class SupportPaginationBar extends StatelessWidget {
//   final SupportSuccess state;
//   const SupportPaginationBar({super.key, required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             onPressed: state.currentPage > 1
//                 ? () => context.read<SupportCubit>().fetchSupportData(
//                     page: state.currentPage - 1,
//                     isRefresh: false,
//                   )
//                 : null,
//             icon: const Icon(Icons.arrow_back_ios, size: 16),
//           ),
//           Text(
//             "Page ${state.currentPage}",
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           IconButton(
//             onPressed: state.hasNextPage
//                 ? () => context.read<SupportCubit>().fetchSupportData(
//                     page: state.currentPage + 1,
//                     isRefresh: false,
//                   )
//                 : null,
//             icon: const Icon(Icons.arrow_forward_ios, size: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
