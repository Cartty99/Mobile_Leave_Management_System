import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveType {
  final String id;
  final String name;
  final int maxDays;
  final double accrualRate;
  final bool requiresDocument;

  LeaveType({
    required this.id,
    required this.name,
    required this.maxDays,
    required this.accrualRate,
    required this.requiresDocument,
  });

  /// Create LeaveType from a Firestore document snapshot
  factory LeaveType.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return LeaveType(
      id: doc.id,
      name: data['name'] as String? ?? '',
      maxDays: (data['maxDays'] is int)
          ? data['maxDays'] as int
          : int.tryParse(data['maxDays']?.toString() ?? '0') ?? 0,
      accrualRate: (data['accrualRate'] is double)
          ? data['accrualRate'] as double
          : double.tryParse(data['accrualRate']?.toString() ?? '0.0') ?? 0.0,
      requiresDocument: data['requiresDocument'] as bool? ?? false,
    );
  }

  /// Optional: create LeaveType from a Map (useful for other cases)
  factory LeaveType.fromMap(Map<String, dynamic> map, String id) {
    return LeaveType(
      id: id,
      name: map['name'] as String? ?? '',
      maxDays: (map['maxDays'] is int)
          ? map['maxDays'] as int
          : int.tryParse(map['maxDays']?.toString() ?? '0') ?? 0,
      accrualRate: (map['accrualRate'] is double)
          ? map['accrualRate'] as double
          : double.tryParse(map['accrualRate']?.toString() ?? '0.0') ?? 0.0,
      requiresDocument: map['requiresDocument'] as bool? ?? false,
    );
  }

  /// Convert to Map (useful for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'maxDays': maxDays,
      'accrualRate': accrualRate,
      'requiresDocument': requiresDocument,
    };
  }
}
