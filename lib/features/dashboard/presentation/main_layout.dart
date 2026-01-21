import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app1/features/settings/presentation/settings_screen.dart';

// --- IMPORTS ---
// Update these paths if your file structure is different
import '../../../core/theme/app_colors.dart';
import 'home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The list of screens for the bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),

    // Placeholder for Booking (Work in Progress)
    const Center(child: Text("Booking Screen")),

    // Placeholder for Chat (Work in Progress)
    const Center(child: Text("Chat Screen")),

    // The New Settings Screen (Replaces Profile)
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Check current theme for dynamic styling
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Navigation Bar Background Color
    final navBarColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightSurface;
    final borderColor = isDarkMode ? Colors.white10 : Colors.black12;

    return Scaffold(
      // The body switches based on the selected index
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
          elevation: 0,
          type: BottomNavigationBarType.fixed,

          // --- COLORS ---
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: isDarkMode ? Colors.grey : Colors.grey[600],

          // --- TYPOGRAPHY (The Fix) ---
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600, // Semi-bold for active tab
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),

          showSelectedLabels: true,
          showUnselectedLabels: true,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: "Book",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings_outlined,
              ), // Changed icon to match "Settings"
              label: "Settings", // Changed label to match "Settings"
            ),
          ],
        ),
      ),
    );
  }
}
