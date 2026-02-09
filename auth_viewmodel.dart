import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = false;
  String? error;
  User? currentUser;

  ///  sign in existing staff member
  Future<bool> signIn(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      currentUser = credential.user;

      // Check if user profile exists in Firestore
      final docRef = _firestore.collection('users').doc(currentUser!.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'firstName': 'Unknown',
          'lastName': 'User',
          'email': currentUser!.email,
          'contact': '',
          'profilePic': '',
        });
      }

      error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message;
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }

  
  User? get user => _auth.currentUser;
}
