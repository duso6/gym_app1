import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 Added for Integer Restriction
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- Form State ---
  final _nameController = TextEditingController(
    text: "Joani Photo",
  ); // 👈 Editable Name
  final _heightController = TextEditingController(text: "180");
  final _weightController = TextEditingController(text: "75");
  String _selectedGender = 'Male';
  String _selectedGoal = 'Muscle Gain';

  // --- Image Picker State ---
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.darkBackground;
    const surfaceColor = AppColors.darkSurface;
    const textColor = Colors.white;
    const labelColor = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Details",
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: surfaceColor,
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path))
                          : null,
                      child: _imageFile == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // 2. Form Fields

            // --- NEW: Name Field ---
            _buildTextField(
              label: "Full Name",
              controller: _nameController,
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              // No "suffix" needed for name
              // Allow text input
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),

            _buildDropdownField(
              label: "Gender",
              value: _selectedGender,
              items: ['Male', 'Female', 'Other'],
              onChanged: (val) => setState(() => _selectedGender = val!),
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
            ),
            const SizedBox(height: 20),

            // --- Height (Integers Only) ---
            _buildTextField(
              label: "Height",
              controller: _heightController,
              suffix: "cm",
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              inputType: TextInputType.number,
              // 👈 This forces integers only
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            // --- Weight (Integers Only) ---
            _buildTextField(
              label: "Weight",
              controller: _weightController,
              suffix: "kg",
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              inputType: TextInputType.number,
              // 👈 This forces integers only
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            _buildDropdownField(
              label: "Goals",
              value: _selectedGoal,
              items: ['Muscle Gain', 'Weight Loss', 'Endurance', 'Flexibility'],
              onChanged: (val) => setState(() => _selectedGoal = val!),
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
            ),
            const SizedBox(height: 40),

            // 3. Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Print values to console to verify
                  debugPrint(
                    "Saving Profile: Name=${_nameController.text}, Height=${_heightController.text}",
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Saved!")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? suffix, // Made optional for Name field
    required Color surfaceColor,
    required Color textColor,
    required Color labelColor,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // 👈 Added formatters support
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: labelColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            inputFormatters: inputFormatters, // 👈 Apply constraints here
            style: GoogleFonts.poppins(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixText: suffix,
              suffixStyle: GoogleFonts.poppins(color: labelColor),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color surfaceColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: labelColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: surfaceColor,
              icon: Icon(Icons.keyboard_arrow_down, color: labelColor),
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
