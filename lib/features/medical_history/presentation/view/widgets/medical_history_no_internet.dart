import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class MedicalHistoryNoInternet extends StatelessWidget {
  final VoidCallback onRetry;
  const MedicalHistoryNoInternet({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No Internet Connection", style: AppStyles.styleBold20Dark),
            const SizedBox(height: 8),
            const Text(
              "We couldn't load your profile. Please check your network.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4E8C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
