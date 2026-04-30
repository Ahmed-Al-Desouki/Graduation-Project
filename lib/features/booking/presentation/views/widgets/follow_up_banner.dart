import 'package:flutter/material.dart';

class FollowUpBanner extends StatelessWidget {
  final String patientName;
  final VoidCallback onClose;

  const FollowUpBanner({
    super.key,
    required this.patientName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Follow-up: $patientName",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
