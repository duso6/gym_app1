import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String classId;
  final Map<String, dynamic> data;

  const ClassDetailsScreen({
    super.key,
    required this.classId,
    required this.data,
  });

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  bool _isLoading = false;
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyBooked();
  }

  // 🕵️‍♂️ Check if user already requested this class
  Future<void> _checkIfAlreadyBooked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('classId', isEqualTo: widget.classId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() => _hasRequested = true);
    }
  }

  // 🚀 The Logic: Send Request
  Future<void> _requestBooking() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    try {
      // 1. Get User Details (for Admin to see who booked)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['fullName'] ?? 'Unknown User';

      // 2. Create Booking Document
      await FirebaseFirestore.instance.collection('bookings').add({
        'classId': widget.classId,
        'className': widget.data['title'],
        'classDate': widget.data['startTime'], // Saved to sort by date
        'userId': user.uid,
        'userName': userName,
        'status': 'pending', // 👈 Critical: Starts as pending
        'requestedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _hasRequested = true);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Request Sent"),
        content: const Text(
          "Your booking request has been sent to the Admin for approval. You will be notified once confirmed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.grey : Colors.black54;

    final startTime = (widget.data['startTime'] as Timestamp).toDate();
    final capacity = widget.data['capacity'] ?? 0;
    final currentBookings = widget.data['currentBookings'] ?? 0;
    final isFull = currentBookings >= capacity;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Hero Image Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.data['imageUrl'] ?? 'https://placehold.co/600x400',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Class Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.data['title'] ?? 'Class',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "\$${widget.data['price'] ?? '15.00'}",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Date & Time Row
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d').format(startTime),
                        style: TextStyle(color: secondaryText),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('h:mm a').format(startTime),
                        style: TextStyle(color: secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "About this class",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.data['description'] ?? "No description available.",
                    style: TextStyle(color: secondaryText, height: 1.5),
                  ),
                  const SizedBox(height: 40),

                  // 3. Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _hasRequested || isFull)
                          ? null
                          : _requestBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _hasRequested
                                  ? "Request Pending"
                                  : isFull
                                  ? "Class Full"
                                  : "Request to Book",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  if (_hasRequested)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text(
                          "You will be notified when Admin approves.",
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
