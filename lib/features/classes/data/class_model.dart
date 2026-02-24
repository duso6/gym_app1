import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startTime;
  final int capacity;
  final int currentBookings; // Number of APPROVED bookings

  ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startTime,
    required this.capacity,
    required this.currentBookings,
  });

  // Convert from Firestore Document
  factory ClassModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ClassModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      capacity: data['capacity'] ?? 0,
      currentBookings: data['currentBookings'] ?? 0,
    );
  }

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startTime': Timestamp.fromDate(startTime),
      'capacity': capacity,
      'currentBookings': currentBookings,
    };
  }
}
