import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/appointment_model.dart';
import 'appointment_card.dart';

class PastAppointmentsSection extends StatelessWidget {
  const PastAppointmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data (بيانات وهمية للتجربة)
    final List<AppointmentModel> appointments = [
      AppointmentModel(
        doctorName: "Dr. Michael Chen",
        specialty: "Endocrinologist",
        date: "Oct 15, 2023",
        title: "Diabetes Follow-up",
        description: "Routine check-up and medication adjustment",
        duration: "45 minutes",
        location: "Room 302",
        imagePath: "https://i.pravatar.cc/150?img=11", // صورة تجريبية
        cardColor: const Color(0xFF3B82F6), // أزرق
      ),
      // AppointmentModel(
      //   doctorName: "Dr. Sarah Williams",
      //   specialty: "Cardiologist",
      //   date: "Sep 22, 2023",
      //   title: "Hypertension Management",
      //   description: "Blood pressure monitoring and medication review",
      //   duration: "30 minutes",
      //   location: "Cardiology Wing",
      //   imagePath: "https://i.pravatar.cc/150?img=5",
      //   cardColor: const Color(0xFFEF4444), // أحمر
      // ),
      // AppointmentModel(
      //   doctorName: "Dr. James Rodriguez",
      //   specialty: "Pulmonologist",
      //   date: "Aug 10, 2023",
      //   title: "Asthma Review",
      //   description: "Lung function test and inhaler technique review",
      //   duration: "60 minutes",
      //   location: "Pulmonary Lab",
      //   imagePath: "https://i.pravatar.cc/150?img=3",
      //   cardColor: const Color(0xFF14B8A6), // تيل (Teal)
      // ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF), // Light Purple bg
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF9333EA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Past Appointments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to All Appointments
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- Appointments List ---
          // استخدمنا Column بدل ListView عشان إحنا جوه SingleChildScrollView أصلاً في الصفحة الرئيسية
          ...appointments.map(
            (appointment) => AppointmentCard(appointment: appointment),
          ),
        ],
      ),
    );
  }
}
