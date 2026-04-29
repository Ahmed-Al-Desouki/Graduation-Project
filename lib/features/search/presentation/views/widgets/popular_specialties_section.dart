import 'package:flutter/material.dart';

class PopularSpecialtiesSection extends StatelessWidget {
  final String selectedSpecialty;
  final List<String> popularSpecialties;
  final Function(String) onSelected;

  const PopularSpecialtiesSection({
    super.key,
    required this.selectedSpecialty,
    required this.popularSpecialties,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final specialties = ["All Specialties", ...popularSpecialties];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Specialties",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: specialties.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final specialty = specialties[index];
              final isSelected = specialty == selectedSpecialty;
              return GestureDetector(
                onTap: () => onSelected(specialty),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
