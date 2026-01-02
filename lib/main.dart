import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/weather_market_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/post_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/community_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/language_selection_screen.dart';
import 'utils/constants.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize sqflite for web
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeatherMarketProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/admin': (context) => const AdminLoginScreen(),
          '/language-selection': (context) => const LanguageSelectionScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final localizationProvider = context.read<LocalizationProvider>();
    final authProvider = context.read<AuthProvider>();
    final weatherProvider = context.read<WeatherMarketProvider>();
    final marketplaceProvider = context.read<MarketplaceProvider>();

    await Future.wait([
      localizationProvider.initialize(),
      authProvider.initialize(),
      weatherProvider.initialize(),
      marketplaceProvider.initialize(),
    ]);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check URL for admin route first
    final uri = Uri.base;
    if (uri.path == '/admin' || uri.path == '/admin/') {
      return const AdminLoginScreen();
    }

    if (!_isInitialized) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'HamiKisan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Together We Farm',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
