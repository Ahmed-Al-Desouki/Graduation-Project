import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_location_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_tile.dart';

class InfoSection extends StatelessWidget {
  final dynamic profile;
  final bool isEditable;
  const InfoSection({super.key, required this.profile, this.isEditable = true});

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
                  Text(
                    "Doctor Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (isEditable)
                    TextButton(
                      onPressed: () {
                        _showEditLocationSheet(context, profile);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF2563EB), size: 17),
                          SizedBox(width: 5),
                          Text(
                            "Edit",
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

              SizedBox(height: 20),
              InfoTile(
                imageAsset: Assets.imagesCertificate,
                iconColor: Colors.orange,
                title: "Specializations",
                subtitle: profile.specialization,
              ),
              if (profile.hospitalName != null) ...[
                const SizedBox(height: 15),
                InfoTile(
                  imageAsset: Assets.imagesHospital,
                  iconColor: Colors.green,
                  title: "Clinic",
                  subtitle: profile.hospitalName!,
                ),
              ],
              if (profile.clinicAddress != null) ...[
                const SizedBox(height: 15),
                InfoTile(
                  icon: Icons.location_on,
                  iconColor: Colors.purple,
                  title: "Location",
                  subtitle: profile.clinicAddress!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditLocationSheet(
    BuildContext context,
    DoctorProfileEntity profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<DoctorRealProfileCubit>(),
            child: EditLocationSheet(profile: profile),
          ),
    );
  }
}
