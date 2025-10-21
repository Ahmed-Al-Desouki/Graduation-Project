import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:intl/intl.dart';

class PersonalInformationSectionForPatient extends StatefulWidget {
  final Function(bool)? onFormValidChanged;
  final Function(String?)? onGenderChanged;
  final TextEditingController ageController;
  final TextEditingController birthDateController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  String? gender;

  PersonalInformationSectionForPatient({
    super.key,
    this.onFormValidChanged,
    this.onGenderChanged,
    required this.ageController,
    required this.birthDateController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    this.gender,
  });

  @override
  State<PersonalInformationSectionForPatient> createState() =>
      _PersonalInformationSectionState();
}

class _PersonalInformationSectionState
    extends State<PersonalInformationSectionForPatient> {
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
        widget.gender != null;

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
            imagePath: Assets.imagesMobile,
            title: "Emergency Contact (Optional)",
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomFormTextField(
                  hintText: "Full Name",
                  imagePath: Assets.imagesUserRegular,
                  fieldType: FieldType.name,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  // icon: const Icon(Icons.person),
                  decoration: InputDecoration(
                    labelText: "Relationship",
                    labelStyle: AppStyles.styleRegular16Gray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Dad", child: Text("Dad")),
                    DropdownMenuItem(value: "Mother", child: Text("Mother")),
                    DropdownMenuItem(value: "Brother", child: Text("Brother")),
                    DropdownMenuItem(value: "Sister", child: Text("Sister")),
                    DropdownMenuItem(value: "Spouse", child: Text("Spouse")),
                    DropdownMenuItem(
                      value: "Colleague",
                      child: Text("Colleague"),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            hintText: "Phone Number",
            imagePath: Assets.imagesMobile,
            fieldType: FieldType.nationalId,
          ),
        ],
      ),
    );
  }
}
