import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Please login to see messages"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      // 🔥 Listen to all chats where this user is a participant
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser.uid)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No messages yet.",
                    style: GoogleFonts.poppins(color: secondaryText),
                  ),
                  const SizedBox(height: 20),
                  // DEMO BUTTON: This allows you to start a chat with the "Admin" easily to test it
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatDetailScreen(
                            receiverId:
                                "admin_user_id_123", // Dummy ID for testing
                            receiverName: "Gym Admin",
                            avatarUrl:
                                "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                    ),
                    child: const Text(
                      "Contact Admin",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? Colors.white10 : Colors.black12,
              height: 1,
              indent: 80,
            ),
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;

              // Figure out who the OTHER person is
              List<dynamic> users = chatData['users'];
              String otherUserId = users.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => "unknown",
              );

              // Get their name (from the cached map we saved)
              Map<String, dynamic> userNames = chatData['userNames'] ?? {};
              String otherUserName = userNames[otherUserId] ?? "Gym Staff";

              // Format Time
              String timeStr = "";
              if (chatData['lastUpdated'] != null) {
                final time = (chatData['lastUpdated'] as Timestamp).toDate();
                timeStr = DateFormat('MMM d, h:mm a').format(time);
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark
                      ? Colors.white10
                      : Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                title: Text(
                  otherUserName,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  chatData['lastMessage'] ?? "No messages yet",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                ),
                trailing: Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        receiverId: otherUserId,
                        receiverName: otherUserName,
                        avatarUrl:
                            "https://placehold.co/150", // Add real avatars later
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
