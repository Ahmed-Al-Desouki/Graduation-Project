import 'package:flutter/material.dart';

class VerificationDocumentsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? fileUrl;

  const VerificationDocumentsTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.fileUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              // ✅ لو في صورة، اعرضها
              if (fileUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fileUrl!,
                    height: 150,
                    width: 200,
                    fit: BoxFit.scaleDown,
                    errorBuilder:
                        (_, _, _) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
