import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorCard extends StatelessWidget {
  final int doctorId;
  final String fullName;
  final String imageUrl;
  final String specialty;
  final double rating;
  final int totalReviews;
  final int yearsOfExperience;
  final double consultationFee;
  final bool isActive;
  final double? distanceKm;
  final String? clinicMapUrl;
  final String? directionsMapUrl;

  const DoctorCard({
    super.key,
    required this.doctorId,
    required this.fullName,
    required this.imageUrl,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.isActive,
    this.distanceKm,
    this.clinicMapUrl,
    this.directionsMapUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => context.push(
                          AppRouter.kPublicDoctorProfile,
                          extra: doctorId,
                        ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child:
                          imageUrl.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap:
                              () => context.push(
                                AppRouter.kPublicDoctorProfile,
                                extra: doctorId,
                              ),
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialty,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (directionsMapUrl != null)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.map,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                        onPressed: () => _openMap(context, directionsMapUrl!),
                        tooltip: 'Show directions',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          if (index < rating.floor()) {
                            return Icon(
                              Icons.star,
                              color: Colors.yellow.shade600,
                              size: 18,
                            );
                          } else if (index < rating) {
                            return Icon(
                              Icons.star_half,
                              color: Colors.yellow.shade600,
                              size: 18,
                            );
                          }
                          return Icon(
                            Icons.star_border,
                            color: Colors.yellow.shade600,
                            size: 18,
                          );
                        }),
                        SizedBox(width: 3.w),
                        Text(
                          rating.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '($totalReviews reviews)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$yearsOfExperience years exp.'),
                    const SizedBox(width: 4),
                    if (distanceKm != null) ...[
                      Icon(
                        Icons.location_on,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${distanceKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        AppRouter.kDoctorSchedule,
                        extra: {
                          'doctorId': doctorId.toString(),
                          'doctorName': fullName,
                          'isPatientView': true,
                          'consultationFee': consultationFee,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMap(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        showSnackBar(context, 'Could not open map', Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Could not open map', Colors.red);
      }
    }
  }
}
