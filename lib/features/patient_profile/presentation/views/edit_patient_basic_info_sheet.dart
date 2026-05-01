import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:intl/intl.dart';

class EditPatientBasicInfoSheet extends StatefulWidget {
  final PatientAccountProfileEntity profile;

  const EditPatientBasicInfoSheet({super.key, required this.profile});

  @override
  State<EditPatientBasicInfoSheet> createState() =>
      _EditPatientBasicInfoSheetState();
}

class _EditPatientBasicInfoSheetState extends State<EditPatientBasicInfoSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(
      text: widget.profile.phoneNumber ?? '',
    );
    _selectedDateOfBirth = widget.profile.dateOfBirth;
    _birthDateController = TextEditingController(
      text: _formatDate(widget.profile.dateOfBirth),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
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
                  'Edit Basic Information',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              CustomFormTextField(
                label: 'Full Name',
                hintText: 'Enter full name',
                fieldType: FieldType.name,
                controller: _fullNameController,
                prefixIcon: Icons.person,
                maxLength: 100,
              ),
              SizedBox(height: 16.h),
              CustomFormTextField(
                label: 'Phone Number',
                hintText: 'Enter phone number',
                fieldType: FieldType.phone,
                controller: _phoneController,
                prefixIcon: Icons.phone,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  if (!RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(text)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomFormTextField(
                label: 'Date of Birth',
                hintText: 'Select date of birth',
                fieldType: FieldType.date,
                controller: _birthDateController,
                prefixIcon: Icons.calendar_month,
                readOnly: true,
                validator: (_) => null,
                onTap: () => _selectDate(context),
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = picked;
      _birthDateController.text = _formatDate(picked);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<PatientAccountProfileCubit>();
    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    Navigator.of(context).pop();

    await cubit.updateHeaderInfo(
      fullName: fullName,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      dateOfBirth: _selectedDateOfBirth,
    );
  }
}
