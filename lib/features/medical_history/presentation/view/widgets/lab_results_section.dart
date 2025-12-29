import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/lab_result_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_file_upload_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

class LabResultsSection extends StatelessWidget {
  final List<MedicalFileModel> labTests;
  final List<MedicalFileModel> radiologyFiles;
  final int medicalHistoryId;

  const LabResultsSection({
    super.key,
    required this.labTests,
    required this.radiologyFiles,
    required this.medicalHistoryId,
  });

  @override
  Widget build(BuildContext context) {
    // دمج القائمتين وتحويلهم لـ Model موحد للعرض
    final List<LabResultModel> combinedList = [
      ...labTests.map(
        (e) => LabResultModel(
          id: e.fileID.toString(),
          title: e.description.isEmpty ? "Lab Test" : e.description,
          date: e.uploadedAt.split('T')[0],
          type: RecordType.lab,
          fileName: e.fileUrl,
        ),
      ),
      ...radiologyFiles.map(
        (e) => LabResultModel(
          id: e.fileID.toString(),
          title: e.description.isEmpty ? "Radiology" : e.description,
          date: e.uploadedAt.split('T')[0],
          type: RecordType.radiology,
          fileName: e.fileUrl,
        ),
      ),
    ];

    // ترتيب حسب التاريخ الأحدث
    combinedList.sort((a, b) => b.date.compareTo(a.date));

    return MedicalSectionCard(
      title: "Lab Results & Radiology",
      icon: Icons.biotech_rounded,
      themeColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFECFEFF),
      emptyMessage: "No records uploaded yet.",

      // زرار الرفع
      onAddTap:
          () => MedicalFileUploadDialog.show(
            context,
            medicalHistoryId,
            context.read<PatientProfileCubit>(),
          ),

      // زرار عرض الكل
      onViewAllTap: () {
        context.push(
          AppRouter.kLabResults, // تأكد إنك ضفت الراوت ده
          extra: {
            'labTests': labTests,
            'radiologyFiles': radiologyFiles,
            'historyId': medicalHistoryId,
            'cubit': context.read<PatientProfileCubit>(),
          },
        );
      },

      children:
          combinedList.take(3).map((item) {
            return LabResultCard(
              result: item,
              onDelete:
                  () => showDeleteConfirmation(
                    context: context,
                    title: "Delete File",
                    message: "Are you sure you want to delete '${item.title}'?",
                    onConfirm: () {
                      context.read<PatientProfileCubit>().deleteMedicalFile(
                        int.parse(item.id),
                      );
                    },
                  ),
            );
          }).toList(),
    );
  }
}
