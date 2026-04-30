import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SlotsEmptyState extends StatelessWidget {
  const SlotsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/Not Found.json',
          width: 180,
          height: 180,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.event_busy, size: 80, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Text(
          "No slots generated for this day.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
