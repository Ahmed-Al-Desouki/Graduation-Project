import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_dialog.dart';
import 'widgets/medical_history_list_layout.dart';

class AllFamilyHistoryView extends StatefulWidget {
  final List<dynamic> allRecords;
  final int historyId;
  final PatientProfileCubit cubit;
  final bool isReadOnly;

  const AllFamilyHistoryView({
    super.key,
    required this.allRecords,
    required this.historyId,
    required this.cubit,
    required this.isReadOnly,
  });

  @override
  State<AllFamilyHistoryView> createState() => _AllFamilyHistoryViewState();
}

class _AllFamilyHistoryViewState extends State<AllFamilyHistoryView> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, state) {
          final list =
              (state is PatientProfileSuccess
                      ? state.profile.familyHistory
                      : widget.allRecords)
                  .where((item) {
                    final q = _query.toLowerCase();
                    return item.condition.toLowerCase().contains(q) ||
                        item.relative.toLowerCase().contains(q);
                  })
                  .toList();

          return MedicalHistoryListLayout(
            title: "Family History",
            searchHint: "Search condition or relative...",
            themeColor: const Color(0xFFFF9800),
            onSearchChanged: (v) => setState(() => _query = v),
            itemCount: list.length,
            emptyMessage: "No records found.",
            onFabPressed:
                widget.isReadOnly
                    ? null
                    : () => FamilyHistoryDialog.show(
                      context,
                      widget.historyId,
                      widget.cubit,
                    ),
            itemBuilder:
                (ctx, i) => FamilyHistoryCard(
                  item: list[i],
                  onEdit:
                      widget.isReadOnly
                          ? null
                          : () => FamilyHistoryDialog.show(
                            context,
                            widget.historyId,
                            widget.cubit,
                            itemToEdit: list[i],
                          ),
                  onDelete:
                      widget.isReadOnly
                          ? null
                          : () => showDeleteConfirmation(
                            context: context,
                            title: "Delete",
                            message: "Delete '${list[i].condition}'?",
                            onConfirm:
                                () => context
                                    .read<PatientProfileCubit>()
                                    .deleteFamilyHistory(
                                      list[i].familyHistoryID!,
                                      widget.historyId,
                                    ),
                          ),
                ),
          );
        },
      ),
    );
  }
}
