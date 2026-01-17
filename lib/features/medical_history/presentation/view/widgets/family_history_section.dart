import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

class FamilyHistorySection extends StatelessWidget {
  final List<FamilyHistoryModel> familyHistory;
  final int historyId;

  const FamilyHistorySection({
    super.key,
    required this.familyHistory,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Family History",
      icon: Icons.family_restroom,
      themeColor: const Color(0xFFFF9800),
      iconBgColor: const Color(0xFFFFF3E0),
      emptyMessage: "No family history recorded.",

      onAddTap:
          () => FamilyHistoryDialog.show(
            context,
            historyId,
            context.read<PatientProfileCubit>(),
          ),

      onViewAllTap: () {
        context.push(
          AppRouter.kAllFamilyHistory,
          extra: {
            'familyHistory': familyHistory,
            'historyId': historyId,
            'cubit': context.read<PatientProfileCubit>(),
          },
        );
      },

      children:
          familyHistory.take(3).map((item) {
            return FamilyHistoryCard(
              item: item,
              onEdit:
                  () => FamilyHistoryDialog.show(
                    context,
                    historyId,
                    context.read<PatientProfileCubit>(),
                    itemToEdit: item,
                  ),
              onDelete:
                  () => showDeleteConfirmation(
                    context: context,
                    title: "Delete Record",
                    message:
                        "Are you sure you want to delete '${item.condition}'?",
                    onConfirm: () {
                      context.read<PatientProfileCubit>().deleteFamilyHistory(
                        item.familyHistoryID!,
                        historyId,
                      );
                    },
                  ),
            );
          }).toList(),
    );
  }
}
