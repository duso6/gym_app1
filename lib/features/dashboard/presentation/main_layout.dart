import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'home_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../shop/presentation/merch_screen.dart'; // 👈 1. Import Merch Screen

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MerchScreen(), // 👈 2. Replace Booking with Merch
    const Center(child: Text("Chat Screen")),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightSurface;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black12;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarColor,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: navBarColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: isDarkMode ? Colors.grey : Colors.grey[600],
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          showSelectedLabels: true,
          showUnselectedLabels: true,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            // 3. Update Icon and Label
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
