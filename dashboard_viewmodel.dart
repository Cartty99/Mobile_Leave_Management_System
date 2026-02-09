import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?>? userStream;
  String? error;
  bool loading = false;

  void listenToUser(String uid) {
    loading = true;
    notifyListeners();

    try {
      userStream = _firestore.collection('users').doc(uid).snapshots().map(
        (doc) {
          if (doc.exists) {
            return UserModel.fromMap(doc.data()!);
          }
          return null;
        },
      );
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
