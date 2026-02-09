import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckLeaveBalanceScreen extends StatefulWidget {
  const CheckLeaveBalanceScreen({super.key});

  @override
  State<CheckLeaveBalanceScreen> createState() => _CheckLeaveBalanceScreenState();
}

class _CheckLeaveBalanceScreenState extends State<CheckLeaveBalanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  Map<String, dynamic> _leaveBalances = {};

  @override
  void initState() {
    super.initState();
    _fetchLeaveBalances();
  }

  Future<void> _fetchLeaveBalances() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get leave types (assuming you have a leaveTypes collection)
      final leaveTypesSnapshot = await _firestore.collection('leaveTypes').get();

      // Get approved leaves for current user
      final leavesSnapshot = await _firestore
          .collection('leaves')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'approved')
          .get();

      Map<String, int> usedDays = {};

      // Calculate total days used per leave type
      for (var doc in leavesSnapshot.docs) {
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final endDate = (data['endDate'] as Timestamp).toDate();
        final days = endDate.difference(startDate).inDays + 1;
        final typeId = data['leaveTypeId'];
        usedDays[typeId] = (usedDays[typeId] ?? 0) + days;
      }

      Map<String, dynamic> balances = {};

      for (var type in leaveTypesSnapshot.docs) {
        final typeData = type.data();
        final name = typeData['name'] ?? 'Unknown';
        final total = typeData['totalDays'] ?? 0;
        final used = usedDays[type.id] ?? 0;
        final remaining = total - used;

        balances[name] = {
          'total': total,
          'used': used,
          'remaining': remaining < 0 ? 0 : remaining,
        };
      }

      setState(() {
        _leaveBalances = balances;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching leave balances: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Leave Balance'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _leaveBalances.isEmpty
              ? const Center(child: Text('No leave balances found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: _leaveBalances.entries.map((entry) {
                      final name = entry.key;
                      final data = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Days: ${data['total']}'),
                              Text('Used Days: ${data['used']}'),
                              Text('Remaining Days: ${data['remaining']}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
