import 'package:flutter/material.dart';

void confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                onConfirm();
                Navigator.pop(ctx);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
  );
}
