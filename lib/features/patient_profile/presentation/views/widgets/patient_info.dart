import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/edit_patient_health_info_sheet.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/widgets/patient_info_tile.dart';

class PatientInfo extends StatelessWidget {
  final PatientAccountProfileEntity profile;

  const PatientInfo({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Patient Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _showEditHealthInfoSheet(context),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF2563EB), size: 17),
                        SizedBox(width: 5),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PatientInfoTile(
                icon: Icons.person,
                iconColor: Colors.blue.shade800,
                label: 'Gender',
                value: _fallbackText(profile.gender, fallback: 'Unknown'),
              ),
              const SizedBox(height: 10),
              PatientInfoTile(
                icon: Icons.bloodtype,
                iconColor: Colors.red,
                label: 'Blood',
                value: _fallbackText(profile.bloodType, fallback: 'N/A'),
              ),
              const SizedBox(height: 10),
              PatientInfoTile(
                icon: Icons.monitor_weight_outlined,
                iconColor: Colors.green,
                label: 'Weight',
                value: '${_formatNumber(profile.weight)} kg',
              ),
              const SizedBox(height: 10),
              PatientInfoTile(
                icon: Icons.height,
                iconColor: Colors.purple,
                label: 'Height',
                value: '${_formatNumber(profile.height)} cm',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fallbackText(String? value, {required String fallback}) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }

  String _formatNumber(double? value) {
    if (value == null) {
      return '0';
    }

    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  void _showEditHealthInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder:
          (_) => BlocProvider.value(
            value: context.read<PatientAccountProfileCubit>(),
            child: EditPatientHealthInfoSheet(profile: profile),
          ),
    );
  }
}
