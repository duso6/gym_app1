import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';     // 👈 For User ID
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 For Database
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- 1. Form State (Now Empty by Default) ---
  final _nameController = TextEditingController();   // 👈 Starts empty
  final _heightController = TextEditingController(); // 👈 Starts empty
  final _weightController = TextEditingController(); // 👈 Starts empty
  
  // Make these nullable (?) so they can start without a value
  String? _selectedGender; 
  String? _selectedGoal;

  bool _isLoading = false; // To show spinner when saving

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
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- 2. The Save Logic (Writes to Firestore) ---
  Future<void> _saveProfile() async {
    // A. Validation: Ensure fields aren't empty
    if (_nameController.text.isEmpty || 
        _heightController.text.isEmpty || 
        _weightController.text.isEmpty ||
        _selectedGender == null ||
        _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // B. Get Current User
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      // C. Prepare Data
      final Map<String, dynamic> userData = {
        "fullName": _nameController.text.trim(),
        "gender": _selectedGender,
        "height": int.parse(_heightController.text.trim()),
        "weight": int.parse(_weightController.text.trim()),
        "fitnessGoal": _selectedGoal,
        "lastUpdated": FieldValue.serverTimestamp(),
        // Note: You would typically upload the image to Firebase Storage here 
        // and get a URL, but for now we are just saving text data.
      };

      // D. Write to Firestore (Merge updates existing fields without deleting others)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Details",
          style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Image Picker
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
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
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
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Form Fields
            _buildTextField(
              label: "Full Name",
              controller: _nameController,
              hint: "Enter your name",
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),

            _buildDropdownField(
              label: "Gender",
              value: _selectedGender,
              hint: "Select Gender", // 👈 Added Hint
              items: ['Male', 'Female', 'Other'],
              onChanged: (val) => setState(() => _selectedGender = val),
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Height",
              controller: _heightController,
              suffix: "cm",
              hint: "0",
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              inputType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: "Weight",
              controller: _weightController,
              suffix: "kg",
              hint: "0",
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
              inputType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),

            _buildDropdownField(
              label: "Goals",
              value: _selectedGoal,
              hint: "Select Goal", // 👈 Added Hint
              items: ['Muscle Gain', 'Weight Loss', 'Endurance', 'Flexibility'],
              onChanged: (val) => setState(() => _selectedGoal = val),
              surfaceColor: surfaceColor,
              textColor: textColor,
              labelColor: labelColor,
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // 3. Connect the Save Function
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                // Show Spinner if loading, else show Text
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
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
    String? suffix,
    String? hint, // 👈 Added Hint support
    required Color surfaceColor,
    required Color textColor,
    required Color labelColor,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: labelColor, fontSize: 14)),
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
            inputFormatters: inputFormatters,
            style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixText: suffix,
              hintText: hint, // 👈 Shows hint when empty
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
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
    required String? value, // 👈 Allow Null
    required String hint,   // 👈 Require Hint
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color surfaceColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: labelColor, fontSize: 14)),
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
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade700)), // 👈 Display hint
              isExpanded: true,
              dropdownColor: surfaceColor,
              icon: Icon(Icons.keyboard_arrow_down, color: labelColor),
              style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}