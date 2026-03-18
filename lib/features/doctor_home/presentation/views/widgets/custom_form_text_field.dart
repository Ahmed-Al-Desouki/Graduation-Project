import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum FieldType {
  name,
  phone,
  number,
  date,
  text,
  license,
  bio,
  fee,
  experience,
  achievementTitle,
  achievementDescription,
}

class CustomFormTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final String? imagePath;
  final IconData? prefixIcon;
  final FieldType fieldType;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final int? minValue;
  final int? maxValue;
  final double? maxFeeValue;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomFormTextField({
    super.key,
    required this.hintText,
    required this.fieldType,
    this.label,
    this.imagePath,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.readOnly = false,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.maxFeeValue,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.number:
      case FieldType.license:
      case FieldType.experience:
      case FieldType.fee:
        return TextInputType.number;
      case FieldType.date:
        return TextInputType.datetime;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.bio:
      case FieldType.achievementDescription:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength!));
    }

    if (widget.fieldType == FieldType.number ||
        widget.fieldType == FieldType.experience ||
        widget.fieldType == FieldType.fee) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    return formatters;
  }

  String? _validate(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    final String text = value?.trim() ?? "";

    // Bio و Achievement Description اختياريين
    if (text.isEmpty &&
        widget.fieldType != FieldType.bio &&
        widget.fieldType != FieldType.achievementDescription) {
      return 'This field is required';
    }

    // Character Length Validation
    if (widget.maxLength != null &&
        text.isNotEmpty &&
        text.length > widget.maxLength!) {
      return 'Maximum ${widget.maxLength} characters allowed';
    }

    switch (widget.fieldType) {
      case FieldType.name:
        if (RegExp(r'^[0-9]').hasMatch(text)) {
          return 'Name cannot start with a number';
        }
        if (text.length > 100) {
          return 'Maximum 100 characters allowed';
        }
        break;

      case FieldType.phone:
        if (text.isNotEmpty && !RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(text)) {
          return 'Enter a valid phone number';
        }
        break;

      case FieldType.number:
      case FieldType.experience:
        final number = int.tryParse(text);
        if (text.isNotEmpty && number == null) {
          return 'Please enter a valid number';
        }
        if (number != null) {
          if (widget.minValue != null && number < widget.minValue!) {
            return 'Minimum value is ${widget.minValue}';
          }
          if (widget.maxValue != null && number > widget.maxValue!) {
            return 'Maximum value is ${widget.maxValue}';
          }
          // Experience specific validation (API: 0-100)
          if (widget.fieldType == FieldType.experience) {
            if (number < 0 || number > 100) {
              return 'Experience must be between 0 and 100 years';
            }
          }
        }
        break;

      case FieldType.fee:
        final fee = double.tryParse(text);
        if (text.isNotEmpty && fee == null) {
          return 'Please enter a valid number';
        }
        if (fee != null) {
          if (fee < 0) {
            return 'Fee cannot be negative';
          }
          // API: 0-10000
          if (fee > 10000) {
            return 'Maximum fee is 10000';
          }
        }
        break;

      case FieldType.license:
        if (text.isNotEmpty && int.tryParse(text) == null) {
          return 'License number must contain numbers only';
        }
        // API: max 20 chars
        if (text.length > 20) {
          return 'Maximum 20 characters allowed';
        }
        break;

      case FieldType.bio:
        // API: max 500 chars
        if (text.length > 500) {
          return 'Maximum 500 characters allowed';
        }
        break;

      case FieldType.achievementTitle:
        // API: max 200 chars
        if (text.length > 200) {
          return 'Maximum 200 characters allowed';
        }
        break;

      case FieldType.achievementDescription:
        // API: max 1000 chars
        if (text.length > 1000) {
          return 'Maximum 1000 characters allowed';
        }
        break;

      default:
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4E8C),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          maxLines: widget.maxLines ?? 1,
          minLines: widget.minLines,
          controller: widget.controller,
          keyboardType: _getKeyboardType(),
          validator: _validate,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: _getInputFormatters(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 14, color: const Color(0xFF9CA3AF)),
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
                            size: 22,
                          )
                          : null),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF1B6E9C),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        // ✅ Character Counter
        if (widget.maxLength != null) ...[
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                      (widget.controller?.text.length ?? 0) > widget.maxLength!
                          ? Colors.red
                          : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// enum FieldType { name, phone, number, date, text, license, bio }

// class CustomFormTextField extends StatefulWidget {
//   final String hintText;
//   final String? label;
//   final String? imagePath;
//   final IconData? prefixIcon;
//   final FieldType fieldType;
//   final TextEditingController? controller;
//   final Function(String)? onChanged;
//   final VoidCallback? onTap;
//   final bool obscureText;
//   final bool readOnly;
//   final int? minLines;
//   final int? maxLines;
//   final int? maxLength;
//   final String? Function(String?)? validator;
//   final List<TextInputFormatter>? inputFormatters;

//   const CustomFormTextField({
//     super.key,
//     required this.hintText,
//     required this.fieldType,
//     this.label,
//     this.imagePath,
//     this.prefixIcon,
//     this.controller,
//     this.onChanged,
//     this.onTap,
//     this.obscureText = false,
//     this.readOnly = false,
//     this.minLines,
//     this.maxLines,
//     this.maxLength,
//     this.validator,
//     this.inputFormatters,
//   });

//   @override
//   State<CustomFormTextField> createState() => _CustomFormTextFieldState();
// }

// class _CustomFormTextFieldState extends State<CustomFormTextField> {
//   TextInputType _getKeyboardType() {
//     switch (widget.fieldType) {
//       case FieldType.number:
//       case FieldType.license:
//         return TextInputType.number;
//       case FieldType.date:
//         return TextInputType.datetime;
//       case FieldType.phone:
//         return TextInputType.phone;
//       case FieldType.bio:
//         return TextInputType.multiline;
//       default:
//         return TextInputType.text;
//     }
//   }

//   String? _validate(String? value) {
//     if (widget.validator != null) {
//       return widget.validator!(value);
//     }

//     final String text = value?.trim() ?? "";

//     if (text.isEmpty && widget.fieldType != FieldType.bio) {
//       return 'This field is required';
//     }

//     switch (widget.fieldType) {
//       case FieldType.name:
//         if (RegExp(r'^[0-9]').hasMatch(text)) {
//           return 'Name cannot start with a number';
//         }
//         break;

//       case FieldType.phone:
//         if (text.isNotEmpty && !RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(text)) {
//           return 'Enter a valid phone number';
//         }
//         break;

//       case FieldType.number:
//         final number = int.tryParse(text);
//         if (text.isNotEmpty && number == null) {
//           return 'Please enter a valid number';
//         }
//         break;

//       case FieldType.license:
//         if (text.isNotEmpty && int.tryParse(text) == null) {
//           return 'License number must contain numbers only';
//         }
//         break;

//       default:
//         break;
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (widget.label != null) ...[
//           Text(
//             widget.label!,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF1B4E8C),
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//         TextFormField(
//           maxLines: widget.maxLines ?? 1,
//           minLines: widget.minLines,
//           controller: widget.controller,
//           keyboardType: _getKeyboardType(),
//           validator: _validate,
//           onChanged: widget.onChanged,
//           onTap: widget.onTap,
//           readOnly: widget.readOnly,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           inputFormatters: widget.inputFormatters,
//           decoration: InputDecoration(
//             hintText: widget.hintText,
//             hintStyle: TextStyle(fontSize: 14, color: const Color(0xFF9CA3AF)),
//             prefixIcon: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child:
//                   widget.imagePath != null
//                       ? SvgPicture.asset(
//                         widget.imagePath!,
//                         width: 22,
//                         height: 22,
//                         colorFilter: const ColorFilter.mode(
//                           Color(0xff9ca3af),
//                           BlendMode.srcIn,
//                         ),
//                       )
//                       : (widget.prefixIcon != null
//                           ? Icon(
//                             widget.prefixIcon,
//                             color: const Color(0xff9ca3af),
//                             size: 22,
//                           )
//                           : null),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 14,
//               horizontal: 16,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF9FAFB),
//             enabledBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(
//                 color: Color(0xFF1B6E9C),
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: Colors.redAccent),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             errorStyle: const TextStyle(
//               color: Colors.redAccent,
//               fontWeight: FontWeight.w500,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
