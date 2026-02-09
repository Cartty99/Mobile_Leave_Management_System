import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveModel {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime createdAt;
  final List<String> supportingDocuments; // URLs

  LeaveModel({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.supportingDocuments,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle cases where supportingDocuments is a single string instead of a list
    List<String> docs = [];
    if (map['supportingDocuments'] != null) {
      if (map['supportingDocuments'] is List) {
        docs = List<String>.from(map['supportingDocuments']);
      } else if (map['supportingDocuments'] is String &&
          map['supportingDocuments'].toString().isNotEmpty) {
        docs = [map['supportingDocuments']];
      }
    }

    return LeaveModel(
      id: id,
      employeeId: map['userId'] ?? '',
      leaveTypeId: map['leaveTypeId'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      reason: map['reason'] ?? '',
      status: _statusFromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      supportingDocuments: docs,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': employeeId,
        'leaveTypeId': leaveTypeId,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'reason': reason,
        'status': status.toString().split('.').last,
        'createdAt': Timestamp.fromDate(createdAt),
        'supportingDocuments': supportingDocuments,
      };

  static LeaveStatus _statusFromString(String s) {
    switch (s) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      case 'cancelled':
        return LeaveStatus.cancelled;
      default:
        return LeaveStatus.pending;
    }
  }
}
