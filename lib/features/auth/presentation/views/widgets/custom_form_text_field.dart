import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

enum FieldType {
  name,
  email,
  password,
  age,
  nationalId,
  medicalLicense,
  birthDate,
}

class CustomFormTextField extends StatefulWidget {
  final String hintText;
  final String? imagePath;
  final IconData? prefixIcon;
  final FieldType fieldType;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  const CustomFormTextField({
    super.key,
    required this.hintText,
    required this.fieldType,
    this.imagePath,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.minLines,
    this.maxLines,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  bool _isPasswordVisible = false;

  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.age:
      case FieldType.nationalId:
      case FieldType.medicalLicense:
        return TextInputType.number;
      case FieldType.email:
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  String? _validate(String? value) {
    final String text = value?.trim() ?? "";
    if (text.isEmpty) {
      if (widget.fieldType == FieldType.birthDate) {
        return 'Please select a birth date';
      }
      return 'This field is required';
    }

    switch (widget.fieldType) {
      case FieldType.name:
        if (RegExp(r'^[0-9]').hasMatch(text)) {
          return 'Name cannot start with a number';
        }
        break;

      case FieldType.email:
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(text)) {
          return 'Enter a valid email format';
        }
        if (!text.endsWith('@gmail.com')) {
          return 'Email must be a @gmail.com address';
        }
        break;

      case FieldType.password:
        if (text.length < 6) {
          return 'Password must be at least 6 characters';
        }
        break;

      case FieldType.age:
        final age = int.tryParse(text);
        if (age == null) {
          return 'Please enter a valid number';
        }
        if (age < 18) {
          return 'Age must be 18 or older';
        }
        break;

      case FieldType.nationalId:
        if (text.length != 14) {
          return 'National ID must be 14 digits';
        }
        if (int.tryParse(text) == null) {
          return 'National ID must contain numbers only';
        }
        break;

      case FieldType.birthDate:
        break;

      default:
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.fieldType == FieldType.password;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: TextFormField(
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines,
        controller: widget.controller,
        obscureText: isPasswordField && !_isPasswordVisible,
        keyboardType: _getKeyboardType(),
        validator: _validate,
        onChanged: widget.onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppStyles.styleRegular16Gray,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                widget.imagePath != null
                    ? SvgPicture.asset(
                      widget.imagePath!,
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        Color(0xff9ca3af),
                        BlendMode.srcIn,
                      ),
                    )
                    : (widget.prefixIcon != null
                        ? Icon(
                          widget.prefixIcon,
                          color: const Color(0xff9ca3af),
                        )
                        : null),
          ),
          suffixIcon:
              isPasswordField
                  ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xff9ca3af),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                  : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffd1d5db)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A72DA), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
