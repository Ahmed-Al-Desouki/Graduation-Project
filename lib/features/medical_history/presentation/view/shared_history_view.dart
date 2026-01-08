import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedHistoryView extends StatefulWidget {
  final String token;
  const SharedHistoryView({super.key, required this.token});

  @override
  State<SharedHistoryView> createState() => _SharedHistoryViewState();
}

class _SharedHistoryViewState extends State<SharedHistoryView> {
  @override
  void initState() {
    super.initState();
    context.read<MedicalqrCubit>().fetchSharedHistory(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Shared Medical Record"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocBuilder<MedicalqrCubit, MedicalqrState>(
        builder: (context, state) {
          if (state is SharedHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SharedHistoryFailure) {
            return _buildErrorWidget(state.errMessage);
          } else if (state is SharedHistorySuccess) {
            final data = state.profile; // هذا هو PatientProfileModel الخاص بك
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. كارت المعلومات الشخصية
                  _buildHeaderInfo(data),
                  const SizedBox(height: 16),

                  // 2. القياسات الحيوية
                  _buildVitalSigns(data),
                  const SizedBox(height: 16),

                  // 3. الحساسية والأمراض المزمنة
                  _buildStatusSection(
                    "Conditions & Allergies",
                    Icons.warning_amber_rounded,
                    Colors.orange,
                    [
                      _buildChipList(
                        "Allergies",
                        data.allergies,
                        Colors.red.shade100,
                        Colors.red,
                      ),
                      const SizedBox(height: 10),
                      _buildChipList(
                        "Chronic Conditions",
                        data.chronicConditions,
                        Colors.blue.shade100,
                        Colors.blue.shade800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. التاريخ الاجتماعي (Social History)
                  if (data.socialHistory != null)
                    _buildSocialHistory(data.socialHistory!),

                  const SizedBox(height: 16),

                  // 🔥 5. التحاليل الطبية (Lab Results) - جديد
                  _buildFilesSection(
                    "Lab Results",
                    data.labTests,
                    Icons.science_outlined,
                    Colors.indigo,
                  ),
                  const SizedBox(height: 16),

                  // 🔥 6. الأشعة (Radiology Files) - جديد
                  _buildFilesSection(
                    "Radiology Reports",
                    data.radiologyFiles,
                    Icons.image_outlined,
                    Colors.deepOrange,
                  ),
                  const SizedBox(height: 16),

                  // 5. الأدوية (Current + Self)
                  _buildMedicationsSection(data),

                  const SizedBox(height: 16),

                  // 6. العمليات الجراحية
                  _buildSurgeriesSection(data.surgeries),

                  const SizedBox(height: 16),

                  // 7. تاريخ العائلة
                  _buildFamilyHistorySection(data.familyHistory),

                  const SizedBox(height: 30),
                  const Text(
                    "End of Record",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeaderInfo(data) {
    return _buildCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade100,
            child:
                NetworkImage(data.profileImageUrl) != ""
                    ? ClipOval(
                      child: Image.network(
                        data.profileImageUrl,
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Icon(Icons.person, size: 40, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.fullName, style: AppStyles.styleBold20Dark),
                Text(
                  data.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _buildSmallBadge(data.gender, Colors.blue),
                    const SizedBox(width: 5),
                    _buildSmallBadge("${data.age} Years", Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSigns(data) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            "Weight",
            "${data.weight} kg",
            Icons.monitor_weight_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            "Height",
            "${data.height} cm",
            Icons.height,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            "Blood",
            data.bloodType ?? "N/A",
            Icons.bloodtype_outlined,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialHistory(social) {
    return _buildStatusSection(
      "Social History",
      Icons.people_outline,
      Colors.teal,
      [
        _buildRow("Smoking", social.smokingStatus),
        _buildRow("Alcohol", social.alcoholUse),
        if (social.occupation != null)
          _buildRow("Occupation", social.occupation!),
        if (social.exercise != null) _buildRow("Exercise", social.exercise!),
      ],
    );
  }

  Widget _buildMedicationsSection(data) {
    final allMeds = [
      ...data.currentMedications,
      ...data.patientSelfMedications,
    ];
    return _buildStatusSection(
      "Medications",
      Icons.medication_liquid,
      Colors.purple,
      [
        if (allMeds.isEmpty) const Text("No medications recorded."),
        ...allMeds.map(
          (m) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              m.medicationName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${m.dosage} - ${m.doseInstruction}"),
            trailing: Icon(
              m.isSelfMedication
                  ? Icons.person_outline
                  : Icons.medical_services_outlined,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurgeriesSection(surgeries) {
    return _buildStatusSection(
      "Surgeries",
      Icons.local_hospital_outlined,
      Colors.redAccent,
      [
        if (surgeries.isEmpty) const Text("No surgeries recorded."),
        ...surgeries.map((s) => _buildRow(s.name, s.date ?? "Unknown Date")),
      ],
    );
  }

  Widget _buildFamilyHistorySection(family) {
    return _buildStatusSection(
      "Family History",
      Icons.family_restroom,
      Colors.blueGrey,
      [
        if (family.isEmpty) const Text("No family history recorded."),
        ...family.map(
          (f) => _buildRow(
            "${f.relative}: ${f.condition}",
            "Onset: ${f.onsetAge ?? 'N/A'}",
          ),
        ),
      ],
    );
  }

  Widget _buildFilesSection(
    String title,
    List<MedicalFileModel> files,
    IconData icon,
    Color color,
  ) {
    return _buildStatusSection(title, icon, color, [
      if (files.isEmpty)
        const Text("No files uploaded yet.")
      else
        ...files.map(
          (file) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              file.fileType.toLowerCase().contains('pdf')
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              color: color,
            ),
            title: Text(
              file.description.isEmpty ? "No Description" : file.description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "Uploaded: ${file.uploadedAt.split('T')[0]}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              onPressed: () async {
                final Uri url = Uri.parse(file.fileUrl);
                try {
                  // في الويب، LaunchMode.externalApplication هي الأفضل لفتح الـ PDF في تبويب جديد
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Could not launch $url, error: $e');
                  // اختياري: أظهر SnackBar لو فشل
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not open the file")),
                  );
                }
              },
            ),
          ),
        ),
    ]);
  }

  // --- Helpers ---

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppStyles.styleBold20Dark),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return _buildCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChipList(
    String label,
    List<String> items,
    Color bgColor,
    Color textColor,
  ) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items
                  .map(
                    (i) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        i,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("Failed to load record", style: AppStyles.styleBold20Dark),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
