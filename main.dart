import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view/login_screen.dart';
import 'view/dashboard_screen.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'viewmodel/leave_viewmodel.dart';
import 'viewmodel/profile_viewmodel.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB7apj9Pbek6beBgJ8nPfyIwgc7tQpQ7Ho",
        authDomain: "leave-management-system-a12d5.firebaseapp.com",
        projectId: "leave-management-system-a12d5",
        storageBucket: "leave-management-system-a12d5.firebasestorage.app",
        messagingSenderId: "899725105641",
        appId: "1:899725105641:web:659a1369e599ace1bf9378",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => LeaveViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leave Management - Staff',
        theme: ThemeData(primarySwatch: Colors.indigo),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return const DashboardScreen();
        return const LoginScreen();
      },
    );
  }
}
