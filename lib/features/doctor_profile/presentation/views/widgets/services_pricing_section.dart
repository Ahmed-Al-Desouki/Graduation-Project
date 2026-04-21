import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_services_sheet.dart';

class ServicesPricingSection extends StatelessWidget {
  final double consultationFee;
  const ServicesPricingSection({super.key, required this.consultationFee});

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
                    "Services & Pricing",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _showEditServicesSheet(context, consultationFee);
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

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                        Assets.imagesUserDoctor,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          Colors.purple,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Service fee",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '\$${consultationFee.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditServicesSheet(BuildContext context, double consultationFee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<DoctorRealProfileCubit>(),
            child: EditServicesSheet(currentFee: consultationFee),
          ),
    );
  }
}
