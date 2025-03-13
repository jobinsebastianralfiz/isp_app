import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/ui_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Login user
      await authProvider.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // Check login status
      if (authProvider.loginResponse.isCompleted && authProvider.loginResponse.data == true) {
        // Show success message
        UIHelpers.showToast(message: 'Login successful');

        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (authProvider.loginResponse.isError) {
        // Show error message
        UIHelpers.showSnackBar(
          context,
          message: authProvider.loginResponse.message ?? 'Login failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.loginResponse.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Icon(
                    Icons.wifi,
                    size: 60,
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
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Username field
                  UIHelpers.customTextField(
                    controller: _usernameController,
                    label: 'Username',
                    validator: Validators.validateUsername,
                    keyboardType: TextInputType.name,
                    suffixIcon: const Icon(Icons.person_outline),
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  UIHelpers.customTextField(
                    controller: _passwordController,
                    label: 'Password',
                    validator: Validators.validatePassword,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  UIHelpers.primaryButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}