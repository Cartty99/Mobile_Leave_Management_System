import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/leave_viewmodel.dart';
import 'package:flutter_application_3/model/leave_type_model.dart';

class ApplyLeaveScreen extends StatefulWidget {
  static const routeName = '/applyLeave';

  const ApplyLeaveScreen({super.key});
  @override
  ApplyLeaveScreenState createState() => ApplyLeaveScreenState();
}

class ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  LeaveType? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonCtl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> documents = [];

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<LeaveViewModel>(context, listen: false);

    vm.loadInitialData();       // load user leaves once
    vm.listenToLeaveTypes();    // listen to leave types in real-time
  }

  Future<void> pickDocument() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() {
        documents.add(File(x.path));
      });
    }
  }

  bool get isFormValid {
    if (selectedType == null || startDate == null || endDate == null) return false;
    if (selectedType!.requiresDocument && documents.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LeaveViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Apply Leave')),
      body: vm.loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: ListView(
                children: [
                  DropdownButtonFormField<LeaveType>(
                    decoration: InputDecoration(
                      labelText: 'Select leave type',
                      border: OutlineInputBorder(),
                    ),
                    items: vm.leaveTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.name),
                          ),
                        )
                        .toList(),
                    value: selectedType,
                    onChanged: (v) => setState(() => selectedType = v),
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      startDate == null
                          ? 'Start date'
                          : startDate!.toLocal().toString().split(' ')[0],
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (d != null) setState(() => startDate = d);
                    },
                  ),
                  ListTile(
                    title: Text(
                      endDate == null
                          ? 'End date'
                          : endDate!.toLocal().toString().split(' ')[0],
                    ),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (d != null) setState(() => endDate = d);
                    },
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: reasonCtl,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 12),
                  if (selectedType?.requiresDocument ?? false) ...[
                    ElevatedButton.icon(
                      onPressed: pickDocument,
                      icon: Icon(Icons.attach_file),
                      label: Text('Add document'),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      children: documents
                          .map(
                            (f) => Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(f.path.split('/').last),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () async {
                            await vm.submitLeave(
                              leaveTypeId: selectedType!.id,
                              startDate: startDate!,
                              endDate: endDate!,
                              reason: reasonCtl.text.trim(),
                              documents: documents,
                            );
                            if (!context.mounted) return;
                            if (vm.error == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Leave submitted')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.error!)),
                              );
                            }
                          }
                        : null, // disable button if form is invalid
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
