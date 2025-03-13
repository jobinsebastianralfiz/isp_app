import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for a short time to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize the auth provider
    await authProvider.initialize();

    // Navigate based on login status
    if (authProvider.isLoggedIn) {
      // Navigate to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.wifi,
              size: 80,
              color: AppConstants.primaryColor,
            ),

            const SizedBox(height: 24),

            // App name
            Text(
              'ISP Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            const Text(
              'Your Internet Service Provider',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 48),

            // Loading animation
            SpinKitFadingCircle(
              color: AppConstants.primaryColor,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}