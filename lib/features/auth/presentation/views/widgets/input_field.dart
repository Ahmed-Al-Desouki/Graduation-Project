import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class InputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.validator,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppStyles.styleSemiBold14Dark),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType:
                widget.isPassword
                    ? TextInputType.visiblePassword
                    : TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, color: const Color(0xFF9CA3AF)),
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF9CA3AF),
                        ),
                        onPressed: () {
                          setState(() => _obscureText = !_obscureText);
                        },
                      )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color(0xFF16A34A), width: 2.0),
              ),
              hintText: widget.hint,
            ),
          ),
        ),
      ],
    );
  }
}
