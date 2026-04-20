import 'package:flutter/material.dart';

class RatingRowForHeader extends StatelessWidget {
  final double rating;
  const RatingRowForHeader({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              if (index < rating.floor()) {
                return Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 18,
                );
              } else if (index < rating) {
                return Icon(
                  Icons.star_half,
                  color: Colors.yellow.shade600,
                  size: 18,
                );
              }
              return Icon(
                Icons.star_border,
                color: Colors.yellow.shade600,
                size: 18,
              );
            }),
            const SizedBox(width: 3),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          "(2,847 reviews)",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
