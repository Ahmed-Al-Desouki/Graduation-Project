import 'package:flutter/material.dart';

class MedicalDialogLayout extends StatelessWidget {
  final String title;
  final Color themeColor;
  final Widget child;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final String saveButtonText;

  const MedicalDialogLayout({
    super.key,
    required this.title,
    required this.themeColor,
    required this.child,
    required this.formKey,
    required this.onSave,
    this.saveButtonText = "Save",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(key: formKey, child: SingleChildScrollView(child: child)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onSave,
          child: Text(
            saveButtonText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
