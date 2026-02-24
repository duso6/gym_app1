import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class AdminBookingApprovalScreen extends StatelessWidget {
  const AdminBookingApprovalScreen({super.key});

  // ⚡️ Logic: Approve Booking
  Future<void> _handleBooking(
    String bookingId,
    String classId,
    bool isApproved,
  ) async {
    final firestore = FirebaseFirestore.instance;

    if (isApproved) {
      // 1. Run Transaction to ensure capacity isn't exceeded
      await firestore.runTransaction((transaction) async {
        final classRef = firestore.collection('classes').doc(classId);
        final classSnapshot = await transaction.get(classRef);

        final currentBookings = classSnapshot.get('currentBookings') as int;
        final capacity = classSnapshot.get('capacity') as int;

        if (currentBookings >= capacity) {
          throw Exception("Class is Full!");
        }

        // 2. Increment Count & Update Status
        transaction.update(classRef, {'currentBookings': currentBookings + 1});
        transaction.update(firestore.collection('bookings').doc(bookingId), {
          'status': 'confirmed',
        });
      });
    } else {
      // Just Reject
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'rejected',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body: StreamBuilder<QuerySnapshot>(
        // Only show 'pending' bookings
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;
          if (bookings.isEmpty) {
            return const Center(child: Text("No pending requests."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              // Formatting Timestamp
              final date = (data['classDate'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: AppColors.primaryRed,
                  ),
                  title: Text(data['className'] ?? 'Unknown Class'),
                  subtitle: Text(
                    "User: ${data['userName'] ?? 'Unknown'}\nDate: ${DateFormat('MMM dd, HH:mm').format(date)}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ Reject Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            _handleBooking(booking.id, data['classId'], false),
                      ),
                      // ✅ Approve Button
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          _handleBooking(
                            booking.id,
                            data['classId'],
                            true,
                          ).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
