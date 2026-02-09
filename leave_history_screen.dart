import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/leave_viewmodel.dart';
import '../model/leave_model.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => LeaveHistoryScreenState();
}

class LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Delay data load until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leaveVM = Provider.of<LeaveViewModel>(context, listen: false);
      leaveVM.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave History')),
      body: Consumer<LeaveViewModel>(
        builder: (context, leaveVM, child) {
          if (leaveVM.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (leaveVM.error != null) {
            return Center(child: Text('Error: ${leaveVM.error}'));
          }
          if (leaveVM.leaves.isEmpty) {
            return const Center(child: Text('No leave history found.'));
          }

          return ListView.builder(
            itemCount: leaveVM.leaves.length,
            itemBuilder: (ctx, index) {
              LeaveModel leave = leaveVM.leaves[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${leave.leaveTypeId} (${leave.status})'),
                  subtitle: Text(
                    'From: ${leave.startDate.toLocal().toString().split(' ')[0]} \n'
                    'To: ${leave.endDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: Icon(
                    Icons.circle,
                    color:
                        leave.status == 'approved'
                            ? Colors.green
                            : leave.status == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    size: 12,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/trackLeave', // <-- use your route name
                      arguments: leave, // <-- pass the selected leave model
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
