import 'package:flutter/material.dart';

class RatingRowForHeader extends StatelessWidget {
  const RatingRowForHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) =>
                Icon(Icons.star, color: Colors.yellow.shade600, size: 18),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "4.9 (2,847 reviews)",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
