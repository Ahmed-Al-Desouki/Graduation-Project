import 'package:flutter/material.dart';
import 'package:graduation_project/features/search/data/models/search_item.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_suggestions.dart';

class SearchCard extends StatefulWidget {
  const SearchCard({super.key});

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  final TextEditingController controller = TextEditingController();
  final SearchCubit searchCubit = SearchCubit();

  List<SearchItem> results = [];
  @override
  void dispose() {
    controller.dispose();
    searchCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                onChanged: (value) {
                  searchCubit.onQueryChanged(
                    query: value,
                    onResult: (data) {
                      setState(() => results = data);
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search doctors or specialties",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (results.isNotEmpty) SearchSuggestions(results: results),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_sharp,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 3),
                  const Text("Near you", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Change",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class SearchCard extends StatelessWidget {
//   const SearchCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Transform.translate(
//       offset: const Offset(0, -20),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 12,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search doctors, symptoms, or conditions",
//                   prefixIcon: const Icon(Icons.search),
//                   filled: true,
//                   fillColor: const Color(0xFFF1F5F9),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.location_on_sharp,
//                     size: 18,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(width: 3),
//                   const Text("Near you", style: TextStyle(fontSize: 14)),
//                   const SizedBox(width: 5),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text(
//                       "Change",
//                       style: TextStyle(
//                         color: Color(0xFF2563EB),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
