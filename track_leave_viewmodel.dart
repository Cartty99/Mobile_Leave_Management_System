import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/leave_model.dart';

class TrackLeaveViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LeaveModel? leave;
  bool loading = false;
  String? error;

  Stream<DocumentSnapshot<Map<String, dynamic>>> trackLeave(String leaveId) {
    return _firestore.collection('leave_applications').doc(leaveId).snapshots();
  }

  Future<void> refreshLeave(String leaveId) async {
    loading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('leave_applications').doc(leaveId).get();
      if (doc.exists) {
        leave = LeaveModel.fromMap(doc.data()!, doc.id);
      }
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

