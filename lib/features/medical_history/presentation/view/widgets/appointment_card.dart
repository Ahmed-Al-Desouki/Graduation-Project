// features/medical_history/presentation/view/widgets/appointment_card.dart

import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/appointment_model.dart';
// استدعي الـ AppStyles والـ Assets لو عندك

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          // مهم عشان الشريط الجانبي ياخد الطول كله
          child: Row(
            children: [
              // 1. Colored Side Strip
              Container(width: 6, color: appointment.cardColor),

              // 2. Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header: Avatar + Name + Date ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  appointment.imagePath,
                                ), // لو عندك Assets استخدم AssetImage
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Doctor Name & Specialty
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.doctorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appointment.specialty,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        appointment
                                            .cardColor, // لون التخصص نفس لون الشريط
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Date
                          Text(
                            appointment.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // --- Title ---
                      Text(
                        appointment.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // --- Description ---
                      Text(
                        appointment.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // --- Footer: Time & Location ---
                      Row(
                        children: [
                          _buildFooterItem(
                            Icons.access_time_filled,
                            appointment.duration,
                          ),
                          const SizedBox(width: 16),
                          _buildFooterItem(
                            Icons.location_on,
                            appointment.location,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
