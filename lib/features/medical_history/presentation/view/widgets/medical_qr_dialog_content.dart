import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MedicalQrDialogContent extends StatelessWidget {
  const MedicalQrDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280.w,
      child: BlocBuilder<MedicalqrCubit, MedicalqrState>(
        builder: (context, state) {
          if (state is MedicalQrLoading) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (state is MedicalQrSuccess) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Share Medical History", style: AppStyles.styleBold20Dark),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data:
                        'https://healthcare-9dd79.web.app/share-history?token=${state.token}',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Let the doctor scan this code.\nValid for 10 minutes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            );
          } else if (state is MedicalQrFailure) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                state.errMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox(height: 200);
        },
      ),
    );
  }
}
