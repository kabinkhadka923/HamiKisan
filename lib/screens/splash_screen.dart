import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Add a delay for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        // Navigate to appropriate dashboard based on user role
        final userRole = authProvider.currentUser?.role;
        switch (userRole) {
          case UserRole.farmer:
            Navigator.of(context).pushNamedAndRemoveUntil('/farmerDashboard', (route) => false);
            break;
          case UserRole.kisanDoctor:
            Navigator.of(context).pushNamedAndRemoveUntil('/doctorDashboard', (route) => false);
            break;
          case UserRole.kisanAdmin:
            Navigator.of(context).pushNamedAndRemoveUntil('/kisanAdminDashboard', (route) => false);
            break;
          case UserRole.superAdmin:
            Navigator.of(context).pushNamedAndRemoveUntil('/realAdminDashboard', (route) => false);
            break;
          default:
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Primary Green
              Color(0xFF2E7D32), // Darker Green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 64,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'HamiKisan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Your Digital Farming Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 64),
              
              // Loading indicator
              const SizedBox(
                height: 4,
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
