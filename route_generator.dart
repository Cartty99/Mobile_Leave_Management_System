import 'package:flutter/material.dart';
import '../view/login_screen.dart';
import '../view/dashboard_screen.dart';
import '../view/apply_leave_screen.dart';
import '../view/leave_history_screen.dart';
import '../view/profile_screen.dart';
import '../routes/app_route.dart';
import '../view/update_profile_screen.dart';
import '../view/track_leave_screen.dart';
import '../model/leave_model.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case AppRoutes.applyLeave:
        return MaterialPageRoute(builder: (_) => ApplyLeaveScreen());
      case AppRoutes.trackLeave:
        final leave = settings.arguments as LeaveModel?;
        return MaterialPageRoute(
          builder: (_) => TrackLeaveScreen(leave: leave),
        );

      case AppRoutes.leaveHistory:
        return MaterialPageRoute(builder: (_) => LeaveHistoryScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case UpdateProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Page not found')),
          ),
    );
  }
}
