import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/file_viewer_helper.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart';

class LabResultCard extends StatelessWidget {
  final LabResultModel result;
  final VoidCallback? onDelete;

  const LabResultCard({super.key, required this.result, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isLab = result.type == RecordType.lab;
    final color = isLab ? const Color(0xFF0EA5E9) : const Color(0xFF8B5CF6);
    final icon =
        isLab ? Icons.science_outlined : Icons.document_scanner_outlined;
    final bgIconColor =
        isLab ? const Color(0xFFE0F2FE) : const Color(0xFFF3E8FF);

    return InkWell(
      onTap: () {
        if (result.fileName != null) {
          final extension = result.fileName!.split('?').first.split('.').last;
          final name = "medical_file_${result.id}.$extension";
          FileViewerHelper.openSecureFile(context, result.fileName!, name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File URL is invalid"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgIconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                splashRadius: 20,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
          ],
        ),
      ),
    );
  }
}
