import 'package:flutter/material.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/quick_filter_chip.dart';

class QuickFilters extends StatelessWidget {
  const QuickFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Doctors",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            QuickFilterChip(
              icon: Icons.star,
              text: "Top Rated",
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            QuickFilterChip(
              icon: Icons.check_circle,
              text: "Available Today",
              color: Colors.green,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text("Filters"),
            ),
          ],
        ),
      ],
    );
  }
}
