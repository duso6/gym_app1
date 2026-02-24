import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for Logout
import '../../../core/theme/app_colors.dart';
import 'edit_profile_screen.dart'; // Make sure this import is here
import '../../auth/presentation/login_screen.dart'; // Add this for Logout redirect

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ⚡️ Logout Logic
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.lightText;
    final cardColor = isDarkMode
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- SECTION 1: ACCOUNT ---
          _buildSectionHeader("Account", textColor),
          _buildSettingsContainer(
            cardColor,
            children: [
              _buildListTile(
                icon: Icons.person_outline,
                title: "Edit Profile",
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(isDarkMode),
              // Changed from "Payment Methods" to "Billing Details"
              _buildListTile(
                icon: Icons.credit_card,
                title: "Billing Details",
                textColor: textColor,
                onTap: () {
                  // TODO: Navigate to Billing Screen
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: SUPPORT ---
          // (App Settings / Notifications section completely removed)
          _buildSectionHeader("Support", textColor),
          _buildSettingsContainer(
            cardColor,
            children: [
              _buildListTile(
                icon: Icons.help_outline,
                title: "Help & FAQ",
                textColor: textColor,
                onTap: () {},
              ),
              _buildDivider(isDarkMode),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                textColor: textColor,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 40),

          // --- LOGOUT BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _handleLogout, // 👈 Hooked up the logout logic
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                "Log Out",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: textColor.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(
    Color color, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryRed, size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, color: textColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: textColor.withOpacity(0.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 50, // Starts after the icon
      color: isDarkMode ? Colors.white10 : Colors.black12,
    );
  }
}
