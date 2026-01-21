import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    // These variables allow us to check the current theme mode
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
                title: "Edit Profile", // 👈 Profile is now here
                textColor: textColor,
                onTap: () {
                  // Navigate to Edit Profile Screen
                },
              ),
              _buildDivider(isDarkMode),
              _buildListTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                textColor: textColor,
                onTap: () {},
              ),
              _buildDivider(isDarkMode),
              _buildListTile(
                icon: Icons.credit_card,
                title: "Payment Methods",
                textColor: textColor,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: APP SETTINGS ---
          _buildSectionHeader("App Settings", textColor),
          _buildSettingsContainer(
            cardColor,
            children: [
              SwitchListTile.adaptive(
                activeColor: AppColors.primaryRed,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primaryRed,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Notifications",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              // Note: Dark Mode & Language removed as requested
            ],
          ),

          const SizedBox(height: 24),

          // --- SECTION 3: SUPPORT ---
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
              onPressed: () {
                // Implement Logout Logic
              },
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
