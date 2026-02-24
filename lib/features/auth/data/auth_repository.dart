import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up: Creates Auth User AND Firestore Document
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create User in Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // 2. Create User Document in Firestore AUTOMATICALLY
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'membershipActive': false, // Default to inactive
          'role': 'member', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          // Initialize stats
          'caloriesBurned': 0,
          'workoutsCompleted': 0,
        });
      }
      return user;
    } catch (e) {
      throw e;
    }
  }

  // Login
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
