import 'package:flutter/material.dart';

import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/patient_profile_view.dart';
import 'package:graduation_project/features/search/presentation/views/search_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/home/presentation/views/patient_home_view.dart';

class PatientHomeLayout extends StatefulWidget {
  const PatientHomeLayout({super.key});

  @override
  State<PatientHomeLayout> createState() => _PatientHomeLayoutState();
}

class _PatientHomeLayoutState extends State<PatientHomeLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatientHomeView(),
    SearchView(),
    ChatView(),
    PatientProfileView(),
    SettingsScreen(),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: activeBlue,
          unselectedItemColor: inactiveGray,
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            _buildNavItem(Icons.home_filled, 'Home', 0),
            _buildNavItem(Icons.search_rounded, 'Search', 1),
            _buildNavItem(Icons.chat, 'Chat', 2),
            _buildNavItem(Icons.account_circle_outlined, 'Profile', 3),
            _buildNavItem(Icons.settings, 'Settings', 4),
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
