import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/leave_model.dart';

class TrackLeaveScreen extends StatelessWidget {
  static const routeName = '/trackLeave';
  final LeaveModel? leave;

  const TrackLeaveScreen({super.key, this.leave});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 2;
      case 'rejected':
        return 3;
      case 'pending':
      default:
        return 1;
    }
  }

  void _showStatusDialog(BuildContext context, String status) {
    String title;
    String message;

    switch (status.toLowerCase()) {
      case 'approved':
        title = 'Leave Approved';
        message = 'Your leave application has been approved.';
        break;
      case 'rejected':
        title = 'Leave Rejected';
        message = 'Your leave application was not approved.';
        break;
      case 'pending':
      default:
        title = 'Leave Pending';
        message = 'Your leave application is still awaiting approval.';
        break;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
Widget build(BuildContext context) {
  
  final selectedLeave = leave;

  if (selectedLeave == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Leave Application')),
      body: const Center(
        child: Text(
          'No specific leave selected.\nPlease go to Leave History and select a leave to track.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }


  final docRef = FirebaseFirestore.instance
      .collection('leaves')
      .doc(selectedLeave.id);


    return Scaffold(
      appBar: AppBar(title: const Text('Track Leave Application')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No data found for this application.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'unknown';
          final reason = data['reason'] ?? '';
          final startDate = (data['startDate'] as Timestamp).toDate();
          final endDate = (data['endDate'] as Timestamp).toDate();
          final leaveTypeId = data['leaveTypeId'] ?? '';
          final hodComment = data['hodComment'] ?? 'No comments';
          final createdAt = (data['createdAt'] as Timestamp).toDate();

          final statusColor = _getStatusColor(status);
          final stepIndex = _getStepIndex(status);

          // Show status dialog automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showStatusDialog(context, status);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leave Type: $leaveTypeId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Reason: $reason'),
                    const SizedBox(height: 8),
                    Text(
                      'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                    ),
                    Text(
                      'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('HOD Comment: $hodComment'),
                    const SizedBox(height: 8),
                    Text('Submitted On: ${createdAt.toLocal()}'),
                    const SizedBox(height: 20),
                    const Text(
                      'Application Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stepper(
                      physics: const NeverScrollableScrollPhysics(),
                      currentStep: stepIndex,
                      controlsBuilder:
                          (context, details) => const SizedBox.shrink(),
                      steps: [
                        Step(
                          title: const Text('Submitted'),
                          subtitle: const Text(
                            'Your leave application has been submitted.',
                          ),
                          content: const SizedBox.shrink(),
                          isActive: stepIndex >= 0,
                          state:
                              stepIndex >= 0
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                        Step(
                          title: const Text('Pending'),
                          subtitle: const Text(
                            'Awaiting approval from supervisor.',
                          ),
                          content: const SizedBox.shrink(),
                          isActive: stepIndex >= 1,
                          state:
                              stepIndex == 1
                                  ? StepState.editing
                                  : stepIndex > 1
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                        Step(
                          title: const Text('Approved'),
                          subtitle: const Text('Your leave has been approved.'),
                          content: const SizedBox.shrink(),
                          isActive: stepIndex >= 2,
                          state:
                              status.toLowerCase() == 'approved'
                                  ? StepState.complete
                                  : StepState.indexed,
                        ),
                        Step(
                          title: const Text('Rejected'),
                          subtitle: const Text('Your leave was not approved.'),
                          content: const SizedBox.shrink(),
                          isActive: stepIndex >= 3,
                          state:
                              status.toLowerCase() == 'rejected'
                                  ? StepState.error
                                  : StepState.indexed,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Icon(
                        status == 'approved'
                            ? Icons.check_circle
                            : status == 'rejected'
                            ? Icons.cancel
                            : Icons.hourglass_bottom,
                        color: statusColor,
                        size: 80,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
