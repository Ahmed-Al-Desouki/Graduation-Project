import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, Color backgroundColor) {
  String friendlyMessage = message;
  IconData icon = Icons.info_outline;

  if (message.contains("exception already exists")) {
    icon = Icons.warning_amber_rounded;
  } else if (backgroundColor == Colors.red ||
      message.toLowerCase().contains("error")) {
    icon = Icons.error_outline;
  } else if (backgroundColor == Colors.green) {
    icon = Icons.check_circle_outline;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friendlyMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
  );
}
