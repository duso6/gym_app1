import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';

class AdminCreateClassScreen extends StatefulWidget {
  const AdminCreateClassScreen({super.key});

  @override
  State<AdminCreateClassScreen> createState() => _AdminCreateClassScreenState();
}

class _AdminCreateClassScreenState extends State<AdminCreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  XFile? _imageFile;
  bool _isLoading = false;

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() => _imageFile = image);
  }

  // 📅 Pick Date & Time
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  // 💾 Save to Firestore
  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and pick a time."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Combine Date & Time
      final DateTime finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 2. Upload Image (Simulated for now - in real app use Firebase Storage)
      // For MVP, we will use a placeholder if no image storage is set up yet.
      String imageUrl =
          "https://images.unsplash.com/photo-1571902943202-507ec2618e8f";

      // 3. Write to Firestore
      await FirebaseFirestore.instance.collection('classes').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'currentBookings': 0,
        'startTime': Timestamp.fromDate(finalDateTime),
        'imageUrl': imageUrl, // Todo: Replace with actual storage URL
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Class Created Successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return Scaffold(
      appBar: AppBar(title: const Text("Create New Class")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(15),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(File(_imageFile!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Upload Class Image",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Title
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "Class Title",
                  surfaceColor,
                  isDark,
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 3. Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "Description",
                  surfaceColor,
                  isDark,
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 4. Capacity
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "Max Capacity (e.g., 20)",
                  surfaceColor,
                  isDark,
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 5. Date & Time Picker
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryRed,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDate == null
                            ? "Select Date & Time"
                            : "${DateFormat('MMM dd').format(_selectedDate!)} at ${_selectedTime!.format(context)}",
                        style: GoogleFonts.poppins(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Class",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, Color fillColor, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
