import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_dialog.dart';

class MedicationsSection extends StatelessWidget {
  final List<MedicationModel> medications;
  final int historyId;
  final bool isReadOnly;
  const MedicationsSection({
    super.key,
    required this.medications,
    required this.historyId,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      isReadOnly: isReadOnly,
      title: "Current Medications",
      icon: Icons.medication,
      themeColor: const Color(0xFF9C27B0),
      iconBgColor: const Color(0xFFF3E5F5),
      emptyMessage: "No medications added.",

      onAddTap:
          () => MedicationDialog.show(
            context,
            historyId,
            context.read<PatientProfileCubit>(),
          ),

      onViewAllTap: () {
        context.push(
          AppRouter.kAllMedications,
          extra: {
            'medications': medications,
            'historyId': historyId,
            'cubit': context.read<PatientProfileCubit>(),
            'isReadOnly': isReadOnly,
          },
        );
      },

      children:
          medications.take(3).map((item) {
            return MedicationCard(
              item: item,
              onEdit:
                  isReadOnly
                      ? null
                      : () => MedicationDialog.show(
                        context,
                        historyId,
                        context.read<PatientProfileCubit>(),
                        medToEdit: item,
                      ),
              onDelete:
                  isReadOnly
                      ? null
                      : () => showDeleteConfirmation(
                        context: context,
                        title: "Delete Medication",
                        message:
                            "Are you sure you want to delete '${item.medicationName}'?",
                        onConfirm: () {
                          context
                              .read<PatientProfileCubit>()
                              .deleteSelfMedication(item.currentMedicationID!);
                        },
                      ),
            );
          }).toList(),
    );
  }
}
