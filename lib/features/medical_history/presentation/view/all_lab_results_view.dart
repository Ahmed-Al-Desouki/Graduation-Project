import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/lab_result_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/delete_confirmation_dialog.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/lab_result_card.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_file_upload_dialog.dart';
import 'widgets/medical_history_list_layout.dart';

class AllLabResultsView extends StatefulWidget {
  final List<MedicalFileModel> labTests, radiologyFiles;
  final int historyId;
  final PatientProfileCubit cubit;
  final bool isReadOnly;

  const AllLabResultsView({
    super.key,
    required this.labTests,
    required this.radiologyFiles,
    required this.historyId,
    required this.cubit,
    required this.isReadOnly,
  });

  @override
  State<AllLabResultsView> createState() => _AllLabResultsViewState();
}

class _AllLabResultsViewState extends State<AllLabResultsView> {
  String _query = "";
  DateTimeRange? _range;
  int _typeIdx = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
        builder: (context, state) {
          final labs =
              state is PatientProfileSuccess
                  ? state.profile.labTests
                  : widget.labTests;
          final rads =
              state is PatientProfileSuccess
                  ? state.profile.radiologyFiles
                  : widget.radiologyFiles;

          final list = _combineAndFilter(labs, rads);

          return MedicalHistoryListLayout(
            title: "Medical Files",
            searchHint: "Search files...",
            themeColor: const Color(0xFF06B6D4),
            fabIcon: Icons.cloud_upload,
            onSearchChanged: (v) => setState(() => _query = v),
            selectedDateRange: _range,
            onPickDateRange: _pickDate,
            onClearDateRange: () => setState(() => _range = null),
            filterHeader: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip("All", 0),
                  const SizedBox(width: 8),
                  _buildTypeChip("Lab Results", 1),
                  const SizedBox(width: 8),
                  _buildTypeChip("Radiology", 2),
                ],
              ),
            ),
            itemCount: list.length,
            emptyMessage: "No files found.",
            onFabPressed:
                widget.isReadOnly
                    ? null
                    : () => MedicalFileUploadDialog.show(
                      context,
                      widget.historyId,
                      widget.cubit,
                    ),
            itemBuilder:
                (ctx, i) => LabResultCard(
                  result: list[i],
                  onDelete:
                      widget.isReadOnly
                          ? null
                          : () => showDeleteConfirmation(
                            context: context,
                            title: "Delete File",
                            message:
                                "Are you sure you want to delete '${list[i].title}'?",
                            onConfirm:
                                () => context
                                    .read<PatientProfileCubit>()
                                    .deleteMedicalFile(int.parse(list[i].id)),
                          ),
                ),
          );
        },
      ),
    );
  }

  List<LabResultModel> _combineAndFilter(
    List<dynamic> labs,
    List<dynamic> rads,
  ) {
    final combined = [
      ...labs.map((e) => _mapToFileModel(e, RecordType.lab)),
      ...rads.map((e) => _mapToFileModel(e, RecordType.radiology)),
    ];
    return combined.where((item) {
        final matchSearch = item.title.toLowerCase().contains(
          _query.toLowerCase(),
        );
        bool matchDate =
            _range == null ||
            (DateTime.parse(
                  item.date,
                ).isAfter(_range!.start.subtract(const Duration(days: 1))) &&
                DateTime.parse(
                  item.date,
                ).isBefore(_range!.end.add(const Duration(days: 1))));
        bool matchType =
            _typeIdx == 0 ||
            (_typeIdx == 1
                ? item.type == RecordType.lab
                : item.type == RecordType.radiology);
        return matchSearch && matchDate && matchType;
      }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  LabResultModel _mapToFileModel(dynamic e, RecordType type) {
    return LabResultModel(
      id: e.fileID.toString(),
      title:
          e.description.isEmpty
              ? (type == RecordType.lab ? "Lab Test" : "Radiology")
              : e.description,
      date: e.uploadedAt.split('T')[0],
      type: type,
      fileName: e.fileUrl,
    );
  }

  Widget _buildTypeChip(String txt, int i) => ChoiceChip(
    label: Text(txt),
    selected: _typeIdx == i,
    onSelected: (v) => setState(() => _typeIdx = i),
  );

  void _pickDate() async {
    final p = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (p != null) setState(() => _range = p);
  }
}
