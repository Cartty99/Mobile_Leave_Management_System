import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  bool loading = false;
  bool updateSuccess = false;
  Map<String, dynamic>? profileData;

  /// Load current user profile from Firestore
  Future<void> loadProfile() async {
    loading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      profileData = doc.data();

      // If no image URL, force fallback to default
      if (profileData != null &&
          (profileData!['profilePic'] == null ||
              (profileData!['profilePic'] as String).trim().isEmpty)) {
        profileData!['profilePic'] = null;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Update profile both locally and in Firestore
  Future<void> updateProfile(Map<String, dynamic> newData) async {
    loading = true;
    updateSuccess = false;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      // Update in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update(newData);

      // Reload the latest data from Firestore
      final updatedDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      profileData = updatedDoc.data();

      updateSuccess = true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      updateSuccess = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearUpdateStatus() {
    updateSuccess = false;
    notifyListeners();
  }
}
