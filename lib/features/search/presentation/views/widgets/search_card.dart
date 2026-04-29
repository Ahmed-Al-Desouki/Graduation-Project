import 'package:flutter/material.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/specialty_bottom_sheet_for_search.dart';

class SearchCard extends StatefulWidget {
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final String selectedSpecialty;
  final void Function(String) onSpecialtyChanged;
  final List<String> allSpecializations;

  const SearchCard({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedSpecialty,
    required this.onSpecialtyChanged,
    required this.allSpecializations,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != controller.text) {
      controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displaySpecialty =
        (widget.selectedSpecialty.isEmpty)
            ? "All Specialties"
            : widget.selectedSpecialty;

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
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search doctor",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openSpecialtySheet(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            displaySpecialty.length > 10
                                ? "${displaySpecialty.substring(0, 10)}..."
                                : displaySpecialty,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

  void _openSpecialtySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SpecialtyBottomSheetForSearch(
            allSpecializations: widget.allSpecializations,
            selectedSpecialty: widget.selectedSpecialty,
            onSelected: (value) {
              widget.onSpecialtyChanged(value);
              Navigator.pop(context);
            },
          ),
    );
  }
}
