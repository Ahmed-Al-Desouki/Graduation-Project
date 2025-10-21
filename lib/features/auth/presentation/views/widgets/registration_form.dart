import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RegistrationForm extends StatefulWidget {
  final Function(bool)? onFormValidChanged;
  final Function(String?)? onGenderChanged;
  final TextEditingController ageController;
  final TextEditingController birthDateController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  String? gender;
  bool isDoctor;

  RegistrationForm({
    super.key,
    this.onFormValidChanged,
    this.onGenderChanged,
    required this.ageController,
    required this.birthDateController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    this.gender,
    this.isDoctor = false,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  File? _profileImage;
  double _passwordStrength = 0.0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.passwordController.text.isNotEmpty) {
      _updatePasswordStrength(widget.passwordController.text);
    }
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    if (password.length >= 8) strength += 0.25;

    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      strength += 0.25;
    }

    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    if (password.length < 8 && strength > 0.25) {
      strength = 0.25; //
    } else if (password.length < 8 && strength <= 0.25) {
      strength = 0.1;
    }

    return strength;
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getPasswordStrengthText(double strength) {
    if (strength < 0.3) return "Weak";
    if (strength < 0.7) return "Medium";
    return "Strong";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadersFieldInRegistration(
            imagePath: Assets.imagesUserRegular,
            title: "Personal Information",
          ),
          const SizedBox(height: 10),
          CustomFormTextField(
            controller: widget.nameController,
            hintText: "Full Name",
            imagePath: Assets.imagesUserRegular,
            fieldType: FieldType.name,
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: widget.emailController,
            hintText: "Email Address",
            prefixIcon: Icons.email,
            fieldType: FieldType.email,
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: widget.passwordController,
            hintText: "Password",
            imagePath: Assets.imagesLock,
            fieldType: FieldType.password,
            onChanged:
                (password) => setState(() {
                  _updatePasswordStrength(password);
                }),
          ),
          if (widget.passwordController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey.shade300,
                    color: _getPasswordStrengthColor(_passwordStrength),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPasswordStrengthText(_passwordStrength),
                    style: TextStyle(
                      color: _getPasswordStrengthColor(_passwordStrength),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          HeadersFieldInRegistration(
            imagePath: Assets.imagesCalendarDays,
            title: "Birth & Gender Details",
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomFormTextField(
                  controller: widget.ageController,
                  hintText: "Age",
                  imagePath: Assets.imagesCalendarDays,
                  fieldType: FieldType.age,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 7,
                child: GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      final now = DateTime.now();
                      final age =
                          now.year -
                          pickedDate.year -
                          ((now.month < pickedDate.month ||
                                  (now.month == pickedDate.month &&
                                      now.day < pickedDate.day))
                              ? 1
                              : 0);

                      if (widget.ageController.text.isNotEmpty &&
                          int.tryParse(widget.ageController.text) != age) {
                        ShowSnackBar(
                          context,
                          "The entered age doesn't match the birth date",
                          Colors.red,
                        );
                      }
                      setState(() {
                        widget.birthDateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                        widget.ageController.text = age.toString();
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomFormTextField(
                      hintText: "Birth Date",
                      imagePath: Assets.imagesCalendarDays,
                      fieldType: FieldType.birthDate,
                      controller: widget.birthDateController,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.gender,
            decoration: InputDecoration(
              labelText: "Gender",
              labelStyle: AppStyles.styleRegular16Gray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Male", child: Text("Male")),
              DropdownMenuItem(value: "Female", child: Text("Female")),
            ],
            onChanged: (value) {
              setState(() {
                widget.onGenderChanged?.call(value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a gender';
              }
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          if (widget.isDoctor)
            Column(
              children: [
                const SizedBox(height: 30),
                HeadersFieldInRegistration(
                  imagePath: Assets.imagesCamera,
                  title: "Profile Picture (Optional)",
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffd1d5db)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _profileImage == null
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Upload your professional photo\nJPG, PNG or GIF (max. 5MB)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _profileImage!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
