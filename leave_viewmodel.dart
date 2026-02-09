import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/leave_model.dart';
import '../model/leave_type_model.dart';

class LeaveViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<LeaveModel> leaves = [];
  List<LeaveType> leaveTypes = [];
  bool loading = false;
  String? error;

  Future<void> loadInitialData() async {
    loading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final snapshot = await _firestore
          .collection('leaves')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      leaves = snapshot.docs
          .map((doc) => LeaveModel.fromMap(doc.data(), doc.id))
          .toList();
      error = null;
    } catch (e) {
      error = e.toString();
      debugPrint("Error fetching leaves: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void listenToLeaveTypes() {
    _firestore.collection('leave_types').snapshots().listen((snapshot) {
      leaveTypes = snapshot.docs
          .map((doc) => LeaveType.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<void> submitLeave({
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    List<File>? documents,
  }) async {
    loading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final leaveData = {
        'userId': user.uid,
        'leaveTypeId': leaveTypeId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'reason': reason,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'supportingDocuments': [],
      };

      await _firestore.collection('leaves').add(leaveData);
      await loadInitialData();
      error = null;
    } catch (e) {
      error = e.toString();
      debugPrint("Error submitting leave: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> cancelLeave(String leaveId) async {
    loading = true;
    notifyListeners();

    try {
      await _firestore.collection('leaves').doc(leaveId).update({'status': 'cancelled'});
      await loadInitialData();
    } catch (e) {
      error = e.toString();
      debugPrint("Error cancelling leave: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
