import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_dialog.dart';

class SurgeriesSection extends StatelessWidget {
  final List<SurgeryModel> surgeries;
  final int historyId;

  const SurgeriesSection({
    super.key,
    required this.surgeries,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Surgeries",
      icon: Icons.local_hospital,
      themeColor: const Color(0xFF00ACC1),
      iconBgColor: const Color(0xFFE0F7FA),
      emptyMessage: "No surgeries recorded yet.",

      onAddTap:
          () => SurgeryDialog.show(
            context,
            historyId,
            context.read<PatientProfileCubit>(),
          ),

      onViewAllTap: () {
        context.push(
          AppRouter.kAllSurgeries,
          extra: {
            'surgeries': surgeries,
            'historyId': historyId,
            'cubit': context.read<PatientProfileCubit>(),
          },
        );
      },

      children:
          surgeries.take(3).map((surgery) {
            return SurgeryCard(
              surgery: surgery,
              onEdit:
                  () => SurgeryDialog.show(
                    context,
                    historyId,
                    context.read<PatientProfileCubit>(),
                    surgeryToEdit: surgery,
                  ),
              onDelete:
                  () => showDeleteConfirmation(
                    context: context,
                    title: "Delete Surgery",
                    message:
                        "Are you sure you want to delete '${surgery.name}'?",
                    onConfirm: () {
                      context.read<PatientProfileCubit>().deleteSurgery(
                        surgery.surgeryID!,
                        historyId,
                      );
                    },
                  ),
            );
          }).toList(),
    );
  }
}
