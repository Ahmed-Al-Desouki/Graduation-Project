import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_home.dart';
import 'package:graduation_project/features/auth/presentation/views/setting_view.dart';

// (افترض أن الشاشات الوهمية أعلاه موجودة في نفس الملف أو تم استيرادها)

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  // متغير لتتبع العنصر المحدد حاليًا
  int _selectedIndex = 0;

  // قائمة الشاشات التي سيتم التبديل بينها
  static const List<Widget> _screens = <Widget>[
    PatientHome(),
    // SearchScreen(),
    // ChatScreen(),
    SettingView(),
  ];

  // دالة تُستدعى عند الضغط على أي عنصر في شريط التنقل
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // عرض الشاشة المختارة حاليًا
      backgroundColor: Color(0xffE8F7F2),
      body: Center(child: _screens.elementAt(_selectedIndex)),

      // شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        // الألوان والتصميمات مأخوذة لتطابق الصورة المرفقة
        type: BottomNavigationBarType.fixed, // يجعل جميع الأيقونات مرئية دائمًا
        backgroundColor: Colors.white,
        elevation: 10,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // أيقونة ممتلئة عند الاختيار
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],

        // خصائص التحكم في المظهر
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF4285F4), // لون أزرق ليتناسب مع "Home"
        unselectedItemColor: Color(0xFFC4C4C4,), // لون رمادي فاتح للعناصر غير المختارة
        showUnselectedLabels: true, // لإظهار النصوص تحت العناصر غير المختارة
        // عند الضغط على العنصر
        onTap: _onItemTapped,
      ),
    );
  }
}
