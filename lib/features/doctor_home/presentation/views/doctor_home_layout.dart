import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
// استورد صفحة بروفايل الدكتور هنا

class DoctorHomeLayout extends StatefulWidget {
  const DoctorHomeLayout({super.key});

  @override
  State<DoctorHomeLayout> createState() => _DoctorHomeLayoutState();
}

class _DoctorHomeLayoutState extends State<DoctorHomeLayout> {
  int _currentIndex = 0;

  // شاشات الدكتور (Home, Chat, Profile, Settings)
  final List<Widget> _screens = const [
    DoctorHomeView(), // شاشة هوم الدكتور اللي هتبدأ ترسمها
    ChatView(), // مشتركة (الباك بيفرق بالتوكن)
    Center(
      child: Text("Doctor Profile"),
    ), // استبدلها بـ ProfileView الخاص بالدكتور
    SettingsScreen(), // مشتركة
  ];

  static const Color activeBlue = Color(0xFF1B4E8C);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color inactiveGray = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: activeBlue,
          unselectedItemColor: inactiveGray,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            _buildNavItem(Icons.home_filled, 'Home', 0),
            _buildNavItem(Icons.chat_bubble_outline, 'Messages', 1),
            _buildNavItem(Icons.account_circle_outlined, 'Profile', 2),
            _buildNavItem(Icons.settings_outlined, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final bool isActive = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(icon, color: isActive ? activeBlue : inactiveGray),
          const SizedBox(height: 3),
          if (isActive)
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: activeGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
