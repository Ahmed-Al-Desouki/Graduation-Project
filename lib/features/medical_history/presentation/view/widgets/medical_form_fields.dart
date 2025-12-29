import 'package:flutter/material.dart';

class MedicalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isRequired;
  final bool readOnly;
  final TextInputType keyboardType;
  final int maxLines;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const MedicalTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isRequired = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onTap: onTap,
        style: const TextStyle(fontSize: 14),
        validator:
            isRequired
                ? (val) =>
                    val == null || val.trim().isEmpty
                        ? "$label is required"
                        : null
                : null,
        decoration: InputDecoration(
          labelText: isRequired ? "$label *" : label,
          hintText: hint,
          prefixIcon:
              icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
        ),
      ),
    );
  }
}

class MedicalDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T) itemLabelBuilder;
  final IconData? icon;

  const MedicalDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder(item),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
