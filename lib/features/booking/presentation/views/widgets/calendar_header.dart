import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, Doctor",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "Your Schedule",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // زرار الترس للعودة للإعدادات
          IconButton(
            onPressed: () => AppRouter.router.push(AppRouter.kScheduleSetup),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.settings, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
