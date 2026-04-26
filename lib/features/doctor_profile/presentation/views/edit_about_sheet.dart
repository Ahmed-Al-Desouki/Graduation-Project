import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';

class EditAboutSheet extends StatefulWidget {
  final String? currentDescription;
  const EditAboutSheet({super.key, this.currentDescription});

  @override
  State<EditAboutSheet> createState() => _EditAboutSheetState();
}

class _EditAboutSheetState extends State<EditAboutSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentDescription);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Edit Bio",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            CustomFormTextField(
              hintText:
                  'Brief description about your practice and expertise...',
              fieldType: FieldType.bio,
              controller: _controller,
              prefixIcon: Icons.text_fields_outlined,
              minLines: 1,
              maxLines: 5,
              maxLength: 500,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF754EA6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  final cubit = context.read<DoctorRealProfileCubit>();
                  Navigator.of(context).pop();

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    await cubit.updateBasicInfo(bio: _controller.text);

                    await cubit.getDoctorProfile();
                  });
                },
                child: const Text(
                  "Save Bio",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
