import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/ui_helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Show loading
      UIHelpers.showLoadingDialog(context, message: 'Creating account...');

      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Register user
      await authProvider.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
        address: _addressController.text,
      );

      // Hide loading dialog
      Navigator.of(context).pop();

      // Check registration status
      if (authProvider.registerResponse.isCompleted && authProvider.registerResponse.data == true) {
        // Show success message
        UIHelpers.showToast(message: 'Registration successful');

        // Navigate back to login screen
        Navigator.of(context).pop();
      } else if (authProvider.registerResponse.isError) {
        // Show error message
        UIHelpers.showSnackBar(
          context,
          message: authProvider.registerResponse.message ?? 'Registration failed',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.registerResponse.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: AppConstants.primaryColor,
      ),
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
                  // Title
                  Text(
                    'Create Account',
                    style: AppConstants.headingStyle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // First Name field
                  UIHelpers.customTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: Validators.validateFirstName,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 16),

                  // Last Name field
                  UIHelpers.customTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: Validators.validateLastName,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 16),

                  // Username field
                  UIHelpers.customTextField(
                    controller: _usernameController,
                    label: 'Username',
                    validator: Validators.validateUsername,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  UIHelpers.customTextField(
                    controller: _emailController,
                    label: 'Email',
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Phone Number field
                  UIHelpers.customTextField(
                    controller: _phoneNumberController,
                    label: 'Phone Number',
                    validator: Validators.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  // Address field
                  UIHelpers.customTextField(
                    controller: _addressController,
                    label: 'Address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.streetAddress,
                    maxLines: 2,
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

                  const SizedBox(height: 16),

                  // Confirm Password field
                  UIHelpers.customTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register button
                  UIHelpers.primaryButton(
                    text: 'Register',
                    onPressed: _register,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Login',
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