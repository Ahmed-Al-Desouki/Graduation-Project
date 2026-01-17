import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_list_layout.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgery_dialog.dart';

class AllSurgeriesView extends StatefulWidget {
  final List<SurgeryModel> allSurgeries;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllSurgeriesView({
    super.key,
    required this.allSurgeries,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllSurgeriesView> createState() => _AllSurgeriesViewState();
}

class _AllSurgeriesViewState extends State<AllSurgeriesView> {
  String _query = "";
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, state) {
          final list =
              (state is PatientProfileSuccess
                      ? state.profile.surgeries
                      : widget.allSurgeries)
                  .where((s) {
                    final matchName = s.name.toLowerCase().contains(
                      _query.toLowerCase(),
                    );
                    bool matchDate = true;
                    if (_range != null && s.date != null) {
                      final d = DateTime.parse(s.date!);
                      matchDate =
                          d.isAfter(
                            _range!.start.subtract(const Duration(days: 1)),
                          ) &&
                          d.isBefore(_range!.end.add(const Duration(days: 1)));
                    }
                    return matchName && matchDate;
                  })
                  .toList()
                ..sort((a, b) => (b.date ?? "").compareTo(a.date ?? ""));

          return MedicalHistoryListLayout(
            title: "All Surgeries",
            searchHint: "Search surgeries...",
            themeColor: const Color(0xFF2563EB),
            onSearchChanged: (v) => setState(() => _query = v),
            selectedDateRange: _range,
            onPickDateRange: _pickDate,
            onClearDateRange: () => setState(() => _range = null),
            itemCount: list.length,
            emptyMessage: "No surgeries found.",
            onFabPressed:
                () =>
                    SurgeryDialog.show(context, widget.historyId, widget.cubit),
            itemBuilder:
                (ctx, i) => SurgeryCard(
                  surgery: list[i],
                  onEdit:
                      () => SurgeryDialog.show(
                        context,
                        widget.historyId,
                        widget.cubit,
                        surgeryToEdit: list[i],
                      ),
                  onDelete:
                      () => showDeleteConfirmation(
                        context: context,
                        title: "Delete Surgery",
                        message: "Delete '${list[i].name}'?",
                        onConfirm:
                            () => context
                                .read<PatientProfileCubit>()
                                .deleteSurgery(
                                  list[i].surgeryID!,
                                  widget.historyId,
                                ),
                      ),
                ),
          );
        },
      ),
    );
  }

  void _pickDate() async {
    final p = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (p != null) setState(() => _range = p);
  }
}
