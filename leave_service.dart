import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/leave_model.dart';
import '../model/leave_type_model.dart';

class LeaveService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitLeave(LeaveModel leave) {
    final ref = _db.collection('leaves').doc();
    return ref.set(leave.toMap());
  }

  Future<List<LeaveModel>> fetchLeavesForEmployee(String uid) async {
    final snap =
        await _db
            .collection('leaves')
            .where('employeeId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .get();
    return snap.docs.map((d) => LeaveModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<LeaveType>> fetchLeaveTypes() async {
    final snap = await _db.collection('leaveTypes').get();
    return snap.docs.map((d) => LeaveType.fromMap(d.data(), d.id)).toList();
  }

  Future<void> cancelLeave(String leaveId) {
    return _db.collection('leaves').doc(leaveId).update({
      'status': 'cancelled',
    });
  }

  Future<void> updateLeaveStatus(String leaveId, String status) {
    return _db.collection('leaves').doc(leaveId).update({'status': status});
  }
}
