import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class BookingSuccessView extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingSuccessView({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ أنيميشن نجاح (استخدم Lottie)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 24.h),
              Text(
                "Booking Confirmed!",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                "Your appointment has been successfully booked",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 30.h),

              // 📋 كارت التفاصيل من الـ JSON
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      "Doctor",
                      bookingData['doctorName'] ?? "Doctor",
                    ),
                    _buildInfoRow(
                      "Date",
                      bookingData['appointmentDate'].toString().split('T')[0],
                    ),
                    _buildInfoRow("Time", bookingData['appointmentTime']),
                    _buildInfoRow("Amount", "${bookingData['amount']} EGP"),
                    _buildInfoRow(
                      "Order ID",
                      "#${bookingData['paymobOrderId']}",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // 🏠 زراير التحكم
              ElevatedButton(
                onPressed: () => context.go(AppRouter.kHomePatient),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
