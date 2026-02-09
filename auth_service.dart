import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel> fetchCurrentUserModel() async {
    final user = _auth.currentUser!;
    final snap = await _db.collection('users').doc(user.uid).get();
    return UserModel.fromSnapshot(snap);
    

  }

  Future<void> registerUser({
    required String uid,
    required String name,
    required String surname,
    required String email,
    required String contactDetails,
  }) {
    final ref = _db.collection('users').doc(uid);
    return ref.set({
      'name': name,
      'surname': surname,
      'email': email,
      'contactDetails': contactDetails,
      'role': 'staff',
      'leaveBalance': 0,
      'profilePictureUrl': '',
    });
  }

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
}
