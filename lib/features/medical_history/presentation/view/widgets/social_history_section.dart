import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_form_fields.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_section_card.dart';

class SocialHistorySection extends StatelessWidget {
  final SocialHistoryModel? socialHistory;
  final int historyId;
  final bool isDoctorView;

  const SocialHistorySection({
    super.key,
    required this.socialHistory,
    required this.historyId,
    required this.isDoctorView,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalSectionCard(
      title: "Social History",
      isReadOnly: isDoctorView,
      icon: Icons.people_alt,
      themeColor: const Color(0xFF689F38),
      iconBgColor: const Color(0xFFF1F8E9),
      emptyMessage: "No social history recorded.",

      actionWidget: IconButton(
        onPressed: () => _showEditDialog(context),
        icon: Row(
          children: [
            const Icon(Icons.edit, color: Color(0xFF2563EB), size: 20),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        tooltip: "Edit Social History",
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),

      children:
          socialHistory == null
              ? []
              : [
                _buildRow("Smoking", socialHistory!.smokingStatus),
                if (socialHistory!.smokingDetails?.isNotEmpty == true)
                  _buildSubRow(socialHistory!.smokingDetails!),
                const Divider(height: 24),
                _buildRow("Alcohol", socialHistory!.alcoholUse),
                _buildRow("Drug Use", socialHistory!.drugUse ?? "None"),
                const Divider(height: 24),
                _buildRow("Occupation", socialHistory!.occupation ?? "N/A"),
                _buildRow("Exercise", socialHistory!.exercise ?? "N/A"),
                if (socialHistory!.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      "📝 ${socialHistory!.notes}",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16),
      child: Row(
        children: [
          const Icon(
            Icons.subdirectory_arrow_right,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final smokingController = TextEditingController(
      text: socialHistory?.smokingStatus ?? "Never",
    );
    final smokingDetailsController = TextEditingController(
      text: socialHistory?.smokingDetails ?? "",
    );
    final alcoholController = TextEditingController(
      text: socialHistory?.alcoholUse ?? "Never",
    );
    final drugController = TextEditingController(
      text: socialHistory?.drugUse ?? "None",
    );
    final occupationController = TextEditingController(
      text: socialHistory?.occupation ?? "",
    );
    final exerciseController = TextEditingController(
      text: socialHistory?.exercise ?? "",
    );
    final notesController = TextEditingController(
      text: socialHistory?.notes ?? "",
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Update Social History"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Habits",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    MedicalDropdown<String>(
                      label: "Smoking Status",
                      value: smokingController.text,
                      items: const ["Never", "Former", "Current"],
                      onChanged: (val) => smokingController.text = val!,
                      itemLabelBuilder: (item) => item,
                    ),

                    MedicalTextField(
                      controller: smokingDetailsController,
                      label: "Smoking Details (Optional)",
                    ),

                    MedicalDropdown<String>(
                      label: "Alcohol Use",
                      value: alcoholController.text,
                      items: const ["Never", "Occasional", "Regular"],
                      onChanged: (val) => alcoholController.text = val!,
                      itemLabelBuilder: (item) => item,
                    ),

                    MedicalTextField(
                      controller: drugController,
                      label: "Drug Use",
                      hint: "e.g. None",
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Lifestyle",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    MedicalTextField(
                      controller: occupationController,
                      label: "Occupation",
                    ),
                    MedicalTextField(
                      controller: exerciseController,
                      label: "Exercise",
                      hint: "e.g. 3x/week",
                    ),
                    MedicalTextField(
                      controller: notesController,
                      label: "Additional Notes",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689F38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.read<PatientProfileCubit>().addOrUpdateSocialHistory(
                    SocialHistoryModel(
                      socialHistoryID: socialHistory?.socialHistoryID,
                      historyID: historyId,
                      smokingStatus: smokingController.text,
                      smokingDetails: smokingDetailsController.text,
                      alcoholUse: alcoholController.text,
                      drugUse: drugController.text,
                      occupation: occupationController.text,
                      exercise: exerciseController.text,
                      notes: notesController.text,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
