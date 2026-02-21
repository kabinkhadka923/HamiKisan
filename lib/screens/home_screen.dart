import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_market_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../models/user.dart';
import 'dashboards/farmer_dashboard_screen.dart';
import 'dashboards/kisan_admin_dashboard_screen.dart';
import 'dashboards/real_admin_dashboard_screen.dart';
import 'kisan_doctor/kisan_doctor_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherMarketProvider>().loadWeatherAndMarketData();
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route to role-specific dashboard
    switch (user.role) {
      case UserRole.kisanAdmin:
        return const KisanAdminDashboardScreen();
      case UserRole.superAdmin:
        return const RealAdminDashboardScreen();
      case UserRole.kisanDoctor:
        return KisanDoctorDashboardScreen(doctor: user);
      default:
        return const FarmerDashboardScreen();
    }
  }
}
