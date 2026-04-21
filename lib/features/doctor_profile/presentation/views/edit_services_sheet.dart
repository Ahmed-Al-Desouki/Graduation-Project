import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';

class EditServicesSheet extends StatefulWidget {
  final double currentFee;
  const EditServicesSheet({super.key, required this.currentFee});

  @override
  State<EditServicesSheet> createState() => _EditServicesSheetState();
}

class _EditServicesSheetState extends State<EditServicesSheet> {
  late TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    _feeController = TextEditingController(text: widget.currentFee.toString());
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
              "Edit Consultation Fee",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            CustomFormTextField(
              label: 'Fee (\$)',
              hintText: 'e.g. 150',
              fieldType: FieldType.number,
              controller: _feeController,
              prefixIcon: Icons.attach_money_rounded,
            ),
            //       TextField(
            //   controller: _feeController,
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(labelText: "Consultation Fee"),
            // ),
            SizedBox(height: 32.h),
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
                    final fee = double.tryParse(_feeController.text) ?? 0;

                    await cubit.updateBasicInfo(consultationFee: fee);

                    await cubit.getDoctorProfile();
                  });
                },
                child: const Text(
                  "Save Fee",
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
