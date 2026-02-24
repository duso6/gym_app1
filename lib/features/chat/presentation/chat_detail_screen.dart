import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverId; // 👈 Added: We need the other person's ID
  final String receiverName;
  final String avatarUrl;

  const ChatDetailScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.avatarUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // 🧠 Generate a unique Chat Room ID based on both User IDs
  // This ensures User A and User B always share the exact same chat room
  String getChatRoomId() {
    if (currentUser == null) return "error_room";
    List<String> ids = [currentUser!.uid, widget.receiverId];
    ids.sort(); // Sort alphabetically so it's always the same regardless of who opens it
    return ids.join("_");
  }

  // 🚀 Send Message to Firestore
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    final String messageText = _messageController.text.trim();
    final String chatRoomId = getChatRoomId();
    final timestamp = FieldValue.serverTimestamp();

    // Clear input immediately for snappy UI feel
    _messageController.clear();

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId);

    // 1. Add the message to the 'messages' subcollection
    await chatRef.collection('messages').add({
      'senderId': currentUser!.uid,
      'text': messageText,
      'timestamp': timestamp,
    });

    // 2. Update the parent 'chat' document for the Chat List screen
    await chatRef.set({
      'users': [currentUser!.uid, widget.receiverId],
      'userNames': {
        currentUser!.uid: currentUser!.displayName ?? "User",
        widget.receiverId: widget.receiverName,
      },
      'lastMessage': messageText,
      'lastUpdated': timestamp,
    }, SetOptions(merge: true)); // merge creates it if it doesn't exist

    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black;

    final String chatRoomId = getChatRoomId();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 12),
            Text(
              widget.receiverName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. 🔥 Real-Time Message Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Newest at bottom
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Say hi to ${widget.receiverName}! 👋",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Starts from bottom
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = msgData['senderId'] == currentUser?.uid;

                    // Format time safely
                    String timeStr = "Sending...";
                    if (msgData['timestamp'] != null) {
                      final DateTime time = (msgData['timestamp'] as Timestamp)
                          .toDate();
                      timeStr = DateFormat('h:mm a').format(time);
                    }

                    return _buildChatBubble(
                      msgData['text'] ?? "",
                      timeStr,
                      isMe,
                      isDark,
                    );
                  },
                );
              },
            ),
          ),

          // 2. Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildChatBubble(String text, String time, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryRed
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
