import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ProfileViewModel>(context, listen: false).loadProfile(),
    );
  }

  Future<void> _refreshProfile() async {
    await Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
  }

  ImageProvider<Object> _getProfileImage(String? url) {
  if (url != null && url.trim().isNotEmpty) {
    try {
      return NetworkImage(url);
    } catch (e) {
      debugPrint('Invalid image URL: $url');
    }
  }
  // Always fall back to a local asset
  return const AssetImage('assets/images/default_avatar.png');
}


  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final data = profileVM.profileData;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body:
          profileVM.loading
              ? const Center(child: CircularProgressIndicator())
              : data == null
              ? const Center(child: Text('No profile found.'))
              : RefreshIndicator(
                onRefresh: _refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _getProfileImage(data['profilePic']),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${data['firstName']} ${data['lastName']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Staff Email: ${data['email']}'),
                      Text('Contact: ${data['contact'] ?? 'N/A'}'),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/updateProfile');
                          await _refreshProfile();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes saved successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
