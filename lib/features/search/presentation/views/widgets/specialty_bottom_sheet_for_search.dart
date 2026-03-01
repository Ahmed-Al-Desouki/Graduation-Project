import 'package:flutter/material.dart';

class SpecialtyBottomSheetForSearch extends StatefulWidget {
  final Function(String) onSelected;
  const SpecialtyBottomSheetForSearch({super.key, required this.onSelected});

  @override
  State<SpecialtyBottomSheetForSearch> createState() =>
      _SpecialtyBottomSheetForSearchState();
}

class _SpecialtyBottomSheetForSearchState
    extends State<SpecialtyBottomSheetForSearch> {
  List<String> specialties = [
    "All Specialties",
    "Cardiology",
    "Dermatology",
    "Pediatrics",
    "Orthopedics",
    "Neurology",
    "Gynecology",
    "Dentistry",
    "Anesthesia",
    "Pulmonology",
    "Gastroenterology",
    "Endocrinology",
    "Hematology",
    "Rheumatology",
    "Ophthalmology",
    "Psychiatry",
    "Urology",
    "Plastic Surgery",
  ];

  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    final filtered =
        specialties
            .where((s) => s.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Specialty",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 🔍 search inside specialties
          TextField(
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: "Search specialty",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filtered[index]),
                  onTap: () => widget.onSelected(filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
