// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/search/data/models/search_item.dart';

// class SearchSuggestions extends StatelessWidget {
//   final List<SearchItem> results;
//   const SearchSuggestions({super.key, required this.results});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
//         ],
//       ),
//       child: SizedBox(
//         height: results.length > 4 ? 260 : results.length * 65,
//         child: ListView.builder(
//           itemCount: results.length,
//           itemBuilder: (context, index) {
//             final item = results[index];

//             return Card(
//               color: Color(0xffE8F7F2),
//               elevation: 0,
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(10),
//                 onTap: () {
//                   // بعدين:
//                   // لو Doctor → صفحة الدكتور
//                   // لو Specialty → فلترة
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           item.type == SearchType.doctor
//                               ? Icons.person
//                               : Icons.local_hospital,
//                           color: Colors.blue,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item.title,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               item.type == SearchType.doctor
//                                   ? "Doctor"
//                                   : "Specialty",
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
// // class SearchSuggestions extends StatelessWidget {
// //   final List<SearchItem> results;
// //   const SearchSuggestions({super.key, required this.results});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(top: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
// //         ],
// //       ),
// //       child: ConstrainedBox(
// //         constraints: const BoxConstraints(maxHeight: 250),
// //         child: ListView.separated(
// //           shrinkWrap: true,
// //           physics: const BouncingScrollPhysics(),
// //           itemCount: results.length,
// //           separatorBuilder: (_, _) => const Divider(height: 1),
// //           itemBuilder: (context, index) {
// //             final item = results[index];

// //             return ListTile(
// //               leading: Icon(
// //                 item.type == SearchType.doctor
// //                     ? Icons.person
// //                     : Icons.local_hospital,
// //                 color: Colors.blue,
// //               ),
// //               title: Text(item.title),
// //               subtitle: Text(
// //                 item.type == SearchType.doctor ? "Doctor" : "Specialty",
// //               ),
// //               onTap: () {
// //                 // navigate later
// //               },
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }
