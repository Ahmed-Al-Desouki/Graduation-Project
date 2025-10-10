import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_list_tile_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:intl/intl.dart';

class PersonalInformationSectionForDoctor extends StatefulWidget {
  final Function(bool)? onFormValidChanged;
  final Function(String?)? onGenderChanged;
  final TextEditingController ageController;
  final TextEditingController birthDateController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nationalIdController;
  String? gender;

  PersonalInformationSectionForDoctor({
    super.key,
    this.onFormValidChanged,
    this.onGenderChanged,
    required this.ageController,
    required this.birthDateController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.nationalIdController,
    this.gender,
  });

  @override
  State<PersonalInformationSectionForDoctor> createState() =>
      _PersonalInformationSectionForDoctorState();
}

class _PersonalInformationSectionForDoctorState
    extends State<PersonalInformationSectionForDoctor> {
  File? _profileImage;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFormValidChanged?.call(false);
    });
  }

  bool _isFormValid() {
    bool valid =
        widget.nameController.text.isNotEmpty &&
        widget.emailController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty &&
        widget.ageController.text.isNotEmpty &&
        widget.birthDateController.text.isNotEmpty &&
        widget.gender != null &&
        widget.nationalIdController.text.isNotEmpty;

    widget.onFormValidChanged?.call(valid);
    return valid;
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
            onChanged:
                (_) => setState(() {
                  _isFormValid();
                }),
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: widget.emailController,
            hintText: "Email Address",
            prefixIcon: Icons.email,
            fieldType: FieldType.email,
            onChanged:
                (_) => setState(() {
                  _isFormValid();
                }),
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: widget.passwordController,
            hintText: "Password",
            imagePath: Assets.imagesLock,
            fieldType: FieldType.password,
            onChanged:
                (_) => setState(() {
                  _isFormValid();
                }),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "The entered age doesn't match the birth date",
                            ),
                          ),
                        );
                      }

                      widget.birthDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomFormTextField(
                      hintText: "Birth Date",
                      imagePath: Assets.imagesCalendarDays,
                      fieldType: FieldType.name,
                      controller: widget.birthDateController,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Gender",
              labelStyle: AppStyles.styleRegular16Gray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Male", child: Text("Male")),
              DropdownMenuItem(value: "Female", child: Text("Female")),
              DropdownMenuItem(value: "Other", child: Text("Other")),
            ],
            onChanged: (value) {
              setState(() {
                widget.gender = value!;
                _isFormValid();
              });
            },
          ),
          const SizedBox(height: 30),
          HeadersFieldInRegistration(
            imagePath: Assets.imagesIdentification,
            title: "National ID Number",
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: widget.nationalIdController,
            hintText: "National ID Number",
            prefixIcon: Icons.credit_card,
            fieldType: FieldType.nationalId,
            onChanged:
                (_) => setState(() {
                  _isFormValid();
                }),
          ),
          const SizedBox(height: 20),
          CustomListTileWidget(
            infocolor: const Color(0xff3b82f6),
            icon: Icons.info_outline,
            text:
                "Your National ID is required for verification purposes and will be kept secure.",
          ),
          const SizedBox(height: 30),
          HeadersFieldInRegistration(
            imagePath: Assets.imagesCamera,
            title: "Profile Picture",
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
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
