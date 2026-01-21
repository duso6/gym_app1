import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -----------------------------------------------------------------------------
// Make sure these imports match your folder structure exactly.
// If your folders are different, adjust these lines.
// -----------------------------------------------------------------------------
import 'core/theme/app_colors.dart';
import 'features/dashboard/presentation/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2Easy Gym App',
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
      // 1. 🌗 THEME MODE: This tells Flutter to listen to the phone's settings
      themeMode: ThemeMode.system,

      // 2. ☀️ LIGHT THEME CONFIGURATION
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        primaryColor: AppColors.primaryRed,

        // App Bar Style (Light)
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Card / Surface Style (Light)
        cardColor: AppColors.lightSurface,

        // Typography
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),

      // 3. 🌙 DARK THEME CONFIGURATION
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.primaryRed,

        // App Bar Style (Dark)
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Card / Surface Style (Dark)
        cardColor: AppColors.darkSurface,

        // Typography
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),

      // 4. 🏠 ENTRY POINT
      home: const MainLayout(),
    );
  }
}
