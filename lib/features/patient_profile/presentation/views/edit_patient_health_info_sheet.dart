import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/widgets/dropdown_field.dart';

class EditPatientHealthInfoSheet extends StatefulWidget {
  final PatientAccountProfileEntity profile;

  const EditPatientHealthInfoSheet({super.key, required this.profile});

  @override
  State<EditPatientHealthInfoSheet> createState() =>
      _EditPatientHealthInfoSheetState();
}

class _EditPatientHealthInfoSheetState
    extends State<EditPatientHealthInfoSheet> {
  static const _genders = ['Male', 'Female'];
  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String? _selectedGender;
  String? _selectedBloodType;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: _formatInitialNumber(widget.profile.height),
    );
    _weightController = TextEditingController(
      text: _formatInitialNumber(widget.profile.weight),
    );
    _selectedGender =
        _genders.contains(widget.profile.gender) ? widget.profile.gender : null;
    _selectedBloodType =
        _bloodTypes.contains(widget.profile.bloodType)
            ? widget.profile.bloodType
            : null;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Edit Health Information',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              DropdownField(
                label: 'Gender',
                value: _selectedGender,
                hintText: 'Select gender',
                items: _genders,
                prefixIcon: Icons.person,
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              SizedBox(height: 16.h),

              DropdownField(
                label: 'Blood Type',
                value: _selectedBloodType,
                hintText: 'Select blood type',
                items: _bloodTypes,
                prefixIcon: Icons.bloodtype,
                onChanged:
                    (value) => setState(() => _selectedBloodType = value),
              ),
              SizedBox(height: 16.h),

              CustomFormTextField(
                label: 'Height (cm)',
                hintText: 'Enter height',
                fieldType: FieldType.number,
                controller: _heightController,
                prefixIcon: Icons.height,
                minValue: 0,
                validator: (value) => _validateNumber(value, 'Height'),
              ),
              SizedBox(height: 16.h),

              CustomFormTextField(
                label: 'Weight (kg)',
                hintText: 'Enter weight',
                fieldType: FieldType.number,
                controller: _weightController,
                prefixIcon: Icons.monitor_weight_outlined,
                minValue: 0,
                validator: (value) => _validateNumber(value, 'Weight'),
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4E8C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatInitialNumber(double? value) {
    if (value == null) {
      return '0';
    }

    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String? _validateNumber(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label is required';
    }

    final number = double.tryParse(text);
    if (number == null) {
      return 'Enter a valid $label value';
    }
    if (number < 0) {
      return '$label cannot be negative';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<PatientAccountProfileCubit>();

    Navigator.of(context).pop();

    await cubit.updateHealthInfo(
      gender: _selectedGender,
      bloodType: _selectedBloodType,
      height: double.tryParse(_heightController.text.trim()) ?? 0,
      weight: double.tryParse(_weightController.text.trim()) ?? 0,
    );
  }
}
