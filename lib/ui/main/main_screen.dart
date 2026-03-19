import 'package:air_query/core/theme/app_colors.dart';
import 'package:air_query/ui/home/home_screen.dart';
import 'package:air_query/ui/profile/profile_screen.dart';
import 'package:flutter/material.dart';

/// Main screen that holds the bottom navigation bar and manages
/// tab switching between HomeScreen and ProfileScreen.
/// Uses IndexedStack to preserve state across tab switches.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _homeScreenScrollController = ScrollController();

  @override
  void dispose() {
    _homeScreenScrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      _homeScreenScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  late final _screens = [HomeScreen(scrollController: _homeScreenScrollController,), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
            tooltip: "My Profile",
          ),
        ],
      ),
    );
  }
}
