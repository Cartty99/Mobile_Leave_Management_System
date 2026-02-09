import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = '/updateProfile';
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _firstName;
  String? _lastName;
  String? _contact;
  String? _profilePicUrl;
  File? _imageFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profileData =
        Provider.of<ProfileViewModel>(context, listen: false).profileData;
    _firstName = profileData?['firstName'];
    _lastName = profileData?['lastName'];
    _contact = profileData?['contact'];
    _profilePicUrl = profileData?['profilePic'];
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    String? uploadedUrl = _profilePicUrl;

    // Upload new profile picture if selected
    if (_imageFile != null) {
      uploadedUrl = await _uploadImage(_imageFile!);
    }

    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    await profileVM.updateProfile({
      'firstName': _firstName,
      'lastName': _lastName,
      'contact': _contact,
      'profilePic': uploadedUrl ?? '', // empty string for fallback
    });

    setState(() => _saving = false);

    if (mounted) {
      if (profileVM.updateSuccess) {
        Navigator.pop(context); // Go back to profile screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_profilePicUrl != null &&
                                    _profilePicUrl!.trim().isNotEmpty)
                                ? NetworkImage(_profilePicUrl!)
                                : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  ) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _firstName,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _firstName = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _lastName,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _lastName = v,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _contact,
                      decoration:
                          const InputDecoration(labelText: 'Contact Number'),
                      onSaved: (v) => _contact = v,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
