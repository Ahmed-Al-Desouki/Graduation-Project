import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_list_layout.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medication_dialog.dart';

class AllMedicationsView extends StatefulWidget {
  final List<MedicationModel> allMedications;
  final int historyId;
  final PatientProfileCubit cubit;

  const AllMedicationsView({
    super.key,
    required this.allMedications,
    required this.historyId,
    required this.cubit,
  });

  @override
  State<AllMedicationsView> createState() => _AllMedicationsViewState();
}

class _AllMedicationsViewState extends State<AllMedicationsView> {
  String _query = "";
  DateTimeRange? _range;
  int _sourceIdx = 0, _statusIdx = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, state) {
          final meds =
              state is PatientProfileSuccess
                  ? [
                    ...state.profile.currentMedications,
                    ...state.profile.patientSelfMedications,
                  ]
                  : widget.allMedications;

          final list = _applyFilter(meds);

          return MedicalHistoryListLayout(
            title: "All Medications",
            searchHint: "Search medications...",
            themeColor: const Color(0xFF9C27B0),
            onSearchChanged: (v) => setState(() => _query = v),
            selectedDateRange: _range,
            onPickDateRange: _pickDate,
            onClearDateRange: () => setState(() => _range = null),
            filterHeader: Column(
              children: [
                _buildFilterRow(
                  "Source: ",
                  ["All", "Doctor", "Self"],
                  _sourceIdx,
                  (i) => setState(() => _sourceIdx = i),
                ),
                _buildFilterRow(
                  "Status: ",
                  ["All", "Active", "Completed"],
                  _statusIdx,
                  (i) => setState(() => _statusIdx = i),
                ),
              ],
            ),
            itemCount: list.length,
            emptyMessage: "No medications found.",
            onFabPressed:
                () => MedicationDialog.show(
                  context,
                  widget.historyId,
                  widget.cubit,
                ),
            itemBuilder:
                (ctx, i) => MedicationCard(
                  item: list[i],
                  onEdit:
                      () => MedicationDialog.show(
                        context,
                        widget.historyId,
                        widget.cubit,
                        medToEdit: list[i],
                      ),
                  onDelete:
                      () => showDeleteConfirmation(
                        context: context,
                        title: "Delete",
                        message: "Delete '${list[i].medicationName}'?",
                        onConfirm:
                            () => context
                                .read<PatientProfileCubit>()
                                .deleteSelfMedication(
                                  list[i].currentMedicationID!,
                                ),
                      ),
                ),
          );
        },
      ),
    );
  }

  List<MedicationModel> _applyFilter(List<MedicationModel> input) {
    final now = DateTime.now();

    return input.where((m) {
      final matchSearch = m.medicationName.toLowerCase().contains(
        _query.toLowerCase(),
      );

      bool matchSource =
          _sourceIdx == 0
              ? true
              : (_sourceIdx == 1 ? !m.isSelfMedication : m.isSelfMedication);

      bool matchStatus = true;
      DateTime? endDate =
          m.endDate != null ? DateTime.tryParse(m.endDate!) : null;

      if (_statusIdx == 1) {
        matchStatus = endDate == null || endDate.isAfter(now);
      } else if (_statusIdx == 2) {
        matchStatus = endDate != null && endDate.isBefore(now);
      }

      bool matchDateRange = true;
      if (_range != null) {
        DateTime? startDate =
            m.startDate != null ? DateTime.tryParse(m.startDate!) : null;
        if (startDate != null) {
          final effectiveEndDate = endDate ?? DateTime(2100);
          matchDateRange =
              startDate.isBefore(_range!.end) &&
              effectiveEndDate.isAfter(_range!.start);
        }
      }

      return matchSearch && matchSource && matchStatus && matchDateRange;
    }).toList();
  }

  Widget _buildFilterRow(
    String label,
    List<String> opts,
    int current,
    Function(int) onSel,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        ...List.generate(
          opts.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(opts[i], style: const TextStyle(fontSize: 11)),
              selected: current == i,
              selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
              onSelected: (v) => onSel(i),
            ),
          ),
        ),
      ],
    );
  }

  void _pickDate() async {
    final p = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (p != null) setState(() => _range = p);
  }
}
