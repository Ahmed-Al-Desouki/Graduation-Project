import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:intl/intl.dart';

class ProfileEditForm extends StatefulWidget {
  final PatientProfileModel currentProfile;
  final Function(Map<String, dynamic>) onSave;

  const ProfileEditForm({
    super.key,
    required this.currentProfile,
    required this.onSave,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController ageController;
  late TextEditingController birthDateController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController genderController;

  String? selectedBloodType;

  @override
  void initState() {
    super.initState();
    birthDateController = TextEditingController(
      text: widget.currentProfile.dateOfBirth?.split('T')[0] ?? '',
    );
    ageController = TextEditingController(
      text: widget.currentProfile.age.toString(),
    );
    weightController = TextEditingController(
      text: widget.currentProfile.weight.toString(),
    );
    heightController = TextEditingController(
      text: widget.currentProfile.height.toString(),
    );
    genderController = TextEditingController(
      text: widget.currentProfile.gender,
    );
    selectedBloodType = widget.currentProfile.bloodType;
  }

  @override
  void dispose() {
    birthDateController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: CustomFormTextField(
                      controller: birthDateController,
                      hintText: "YYYY-MM-DD",
                      imagePath: Assets.imagesCalendarDays,
                      fieldType: FieldType.birthDate,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomFormTextField(
                      controller: ageController,
                      hintText: "Age",
                      fieldType: FieldType.age,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Gender", [
                  "Male",
                  "Female",
                ], genderController),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildBloodDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          HeadersFieldInRegistration(
            imagePath: Assets.imagesHeight,
            title: "Body Measurements",
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomFormTextField(
                  controller: weightController,
                  hintText: "Weight (kg)",
                  fieldType: FieldType.number,
                  imagePath: Assets.imagesWeight,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Required";
                    final n = double.tryParse(value);
                    if (n == null) return "Invalid number";
                    if (n < 1) return "Min 1kg";
                    if (n > 300) return "Max 300kg";
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomFormTextField(
                  controller: heightController,
                  hintText: "Height (cm)",
                  fieldType: FieldType.number,
                  imagePath: Assets.imagesHeight,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Required";
                    final n = double.tryParse(value);
                    if (n == null) return "Invalid number";
                    if (n < 20) return "Min 20cm";
                    if (n > 300) return "Max 300cm";
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
              builder: (context, state) {
                if (state is PatientUpdateLoading) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF2563EB,
                      ).withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: null,
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    TextEditingController controller,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(controller.text) ? controller.text : null,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items:
          items
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
      onChanged: (val) {
        if (val != null) setState(() => controller.text = val);
      },
    );
  }

  Widget _buildBloodDropdown() {
    final bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
    return DropdownButtonFormField<String>(
      value: bloodTypes.contains(selectedBloodType) ? selectedBloodType : null,
      decoration: InputDecoration(
        labelText: "Blood Type",
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items:
          bloodTypes
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
      onChanged: (val) {
        setState(() => selectedBloodType = val);
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(birthDateController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final now = DateTime.now();
      int age = now.year - pickedDate.year;
      if (now.month < pickedDate.month ||
          (now.month == pickedDate.month && now.day < pickedDate.day)) {
        age--;
      }
      setState(() {
        birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        ageController.text = age.toString();
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? true) {
      final Map<String, dynamic> updateBody = {
        "dateOfBirth": "${birthDateController.text}T00:00:00Z",
        "gender": genderController.text,
        "bloodType": selectedBloodType ?? "string",
        "height": double.tryParse(heightController.text) ?? 0,
        "weight": double.tryParse(weightController.text) ?? 0,
        "allergies": widget.currentProfile.allergies,
        "chronicConditions": widget.currentProfile.chronicConditions,
        "currentLocation": widget.currentProfile.currentLocation ?? "string",
      };

      widget.onSave(updateBody);
    }
  }
}
