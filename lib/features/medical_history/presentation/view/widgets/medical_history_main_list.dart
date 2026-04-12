import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_header_card.dart';
import 'package:graduation_project/core/widgets/section_showcase_wrapper.dart';
import 'health_profile_section.dart';
import 'family_history_section.dart';
import 'social_history_section.dart';
import 'conditions_allergies_section.dart';
import 'past_appointments_section.dart';
import 'surgeries_section.dart';
import 'medications_section.dart';
import 'lab_results_section.dart';

class MedicalHistoryMainList extends StatelessWidget {
  final bool isDoctorView;
  final PatientProfileModel profile;
  final bool isOffline;
  final int totalSteps;
  final GlobalKey profileKey;
  final GlobalKey familyKey;
  final GlobalKey socialKey;
  final GlobalKey conditionsKey;
  final GlobalKey appointmentsKey;
  final GlobalKey surgeriesKey;
  final GlobalKey medicationsKey;
  final GlobalKey labsKey;

  const MedicalHistoryMainList({
    super.key,
    required this.isDoctorView,
    required this.profile,
    required this.isOffline,
    required this.totalSteps,
    required this.profileKey,
    required this.familyKey,
    required this.socialKey,
    required this.conditionsKey,
    required this.appointmentsKey,
    required this.surgeriesKey,
    required this.medicationsKey,
    required this.labsKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOffline) _buildOfflineBanner(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const MedicalHistoryHeaderCard(),
                const SizedBox(height: 24),

                _wrap(
                  profileKey,
                  'Health Profile',
                  2,
                  HealthProfileSection(
                    isDoctorView: isDoctorView,
                    profile: profile,
                    onSave:
                        (m) => context
                            .read<PatientProfileCubit>()
                            .updateProfileInfo(m),
                  ),
                ),

                _wrap(
                  familyKey,
                  'Family History',
                  3,
                  FamilyHistorySection(
                    isDoctorView: isDoctorView,
                    familyHistory: profile.familyHistory,
                    historyId: profile.medicalHistoryID,
                  ),
                ),

                _wrap(
                  socialKey,
                  'Social History',
                  4,
                  SocialHistorySection(
                    isDoctorView: isDoctorView,
                    socialHistory: profile.socialHistory,
                    historyId: profile.medicalHistoryID,
                  ),
                ),

                _wrap(
                  conditionsKey,
                  'Conditions',
                  5,
                  ConditionsAllergiesSection(
                    isReadOnly: isDoctorView,
                    profile: profile,
                  ),
                ),

                // _wrap(
                //   appointmentsKey,
                //   'Appointments',
                //   6,
                //   const PastAppointmentsSection(),
                // ),
                _wrap(
                  appointmentsKey,
                  'Appointments',
                  6,
                  PastAppointmentsSection(
                    // 🚀 بنبعت المواعيد اللي جات في الـ Profile فعلاً
                    appointments:
                        profile.pastAppointments
                            .cast<AppointmentFullDetailsEntity>(),
                    isDoctorView:
                        isDoctorView, // بنبعت الفلاج ده عشان الكارت يعرف يعرض إيه
                  ),
                ),

                _wrap(
                  surgeriesKey,
                  'Surgeries',
                  7,
                  SurgeriesSection(
                    isReadOnly: isDoctorView,
                    surgeries: profile.surgeries,
                    historyId: profile.medicalHistoryID,
                  ),
                ),

                _wrap(
                  medicationsKey,
                  'Medications',
                  8,
                  MedicationsSection(
                    isReadOnly: isDoctorView,
                    medications: [
                      ...profile.currentMedications,
                      ...profile.patientSelfMedications,
                    ],
                    historyId: profile.medicalHistoryID,
                  ),
                ),

                _wrap(
                  labsKey,
                  'Lab & Radiology',
                  9,
                  LabResultsSection(
                    isReadOnly: isDoctorView,
                    labTests: profile.labTests,
                    radiologyFiles: profile.radiologyFiles,
                    medicalHistoryId: profile.medicalHistoryID,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            "Viewing offline data. Check internet for updates.",
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _wrap(GlobalKey key, String title, int step, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SectionShowcaseWrapper(
        globalKey: key,
        title: title,
        description: 'Update your $title.',
        stepIndex: step,
        totalSteps: totalSteps,
        child: child,
      ),
    );
  }
}
