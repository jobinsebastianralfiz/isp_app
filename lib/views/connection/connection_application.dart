import 'package:flutter/material.dart';
import 'package:ispmanagement/models/connection_models.dart';
import 'package:ispmanagement/models/pacakge_models.dart';
import 'package:ispmanagement/views/connection/documetn%20uoliad.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
// Fixed import (was misspelled as pacakge_models.dart)
import '../../providers/connection_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/ui_helpers.dart';

class ConnectionApplicationForm extends StatefulWidget {
  const ConnectionApplicationForm({Key? key}) : super(key: key);

  @override
  _ConnectionApplicationFormState createState() => _ConnectionApplicationFormState();
}

class _ConnectionApplicationFormState extends State<ConnectionApplicationForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _autoValidate = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    // Pre-fill with user data if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _fullNameController.text = '${user.firstName} ${user.lastName}';
      _emailController.text = user.email;
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Package step - no validation needed as package is already selected
        return true;
      case 1:
        // Personal information step
        return _validatePersonalInfo();
      case 2:
        // Address step
        return _validateAddress();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    return Validators.validateName(_fullNameController.text) == null &&
           Validators.validateEmail(_emailController.text) == null &&
           Validators.validatePhone(_phoneController.text) == null;
  }

  bool _validateAddress() {
    return _validateAddressField(_addressController.text) == null;
  }

  String? _validateAddressField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 10) {
      return 'Please enter a complete address';
    }
    
    // Check for common address components (more flexible)
    final addressParts = trimmedValue.split(RegExp(r'[,\n]'));
    if (addressParts.length < 2) {
      return 'Please include area/locality and city in your address';
    }
    
    // Ensure it's not just repeated characters or very basic input
    if (RegExp(r'^(.)\1{9,}$').hasMatch(trimmedValue.replaceAll(' ', ''))) {
      return 'Please enter a valid address';
    }
    
    return null;
  }

  Future<void> _submitApplication() async {
    setState(() {
      _autoValidate = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Show loading
      UIHelpers.showLoadingDialog(context);

      // Get connection provider
      final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);

      // Submit application
      await connectionProvider.createConnectionApplication(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );

      // Hide loading
      Navigator.of(context).pop();

      // Check result
      if (connectionProvider.applicationResponse.isCompleted &&
          connectionProvider.applicationResponse.data != null) {
        // Success
        _showSuccessDialog(connectionProvider.applicationResponse.data!);
      } else if (connectionProvider.applicationResponse.isError) {
        // Error
        UIHelpers.showSnackBar(
          context,
          message: connectionProvider.applicationResponse.message ?? 'Failed to submit application',
          isError: true,
        );
      }
    }
  }

  void _showSuccessDialog(ConnectionApplication application) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Application Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your connection application has been submitted successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Application ID: ${application.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Status: ${application.status.toUpperCase()}'),
            const SizedBox(height: 16),
            const Text(
              'Please upload required documents to proceed with verification.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.of(context).pop();
              // Navigate to document upload screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DocumentUploadScreen(application: application),
                ),
              );
            },
            child: const Text('Upload Documents'),
          ),
          TextButton(
            onPressed: () {
              // Go back to connections screen
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final selectedPackage = connectionProvider.selectedPackage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Connection'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: selectedPackage == null
          ? _buildNoPackageSelected()
          : _buildApplicationForm(selectedPackage),
    );
  }

  Widget _buildNoPackageSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Package Selected',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please select a package before proceeding',
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm(Package selectedPackage) {
    return Form(
      key: _formKey,
      autovalidateMode: _autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateCurrentStep()) {
            bool isLastStep = _currentStep == 2;

            if (isLastStep) {
              _submitApplication();
            } else {
              setState(() {
                _currentStep++;
              });
            }
          } else {
            setState(() {
              _autoValidate = true;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          } else {
            Navigator.of(context).pop();
          }
        },
        steps: [
          // Package Details Step
          Step(
            title: const Text('Package Details'),
            content: _buildPackageDetailsStep(selectedPackage),
            isActive: _currentStep >= 0,
          ),

          // Personal Information Step
          Step(
            title: const Text('Personal Information'),
            content: _buildPersonalInfoStep(),
            isActive: _currentStep >= 1,
          ),

          // Address Step
          Step(
            title: const Text('Installation Address'),
            content: _buildAddressStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetailsStep(Package package) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppConstants.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider logo if available
                if (package.provider != null && package.provider!['logo'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.network(
                      package.provider!['logo'],
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Text(package.provider!['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                Text(
                  package.name,
                  style: AppConstants.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Speed: ${package.speedDisplay}',
                  style: AppConstants.bodyStyle,
                ),
                Text(
                  'Price: ${package.formattedPrice ?? 'Rs. ${package.price.toStringAsFixed(0)}/month'}',
                  style: AppConstants.bodyStyle,
                ),
                Text(
                  'Validity: ${package.validity}',
                  style: AppConstants.bodyStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  package.description,
                  style: AppConstants.bodyStyle.copyWith(
                    color: AppConstants.lightTextColor,
                  ),
                ),

                if (package.features.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...package.features.take(4).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppConstants.bodyStyle,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),

                  // More features indicator
                  if (package.features.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${package.features.length - 4} more features',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Important Information:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '• Installation will be scheduled after your application is approved\n'
              '• You will need to provide identity and address proof documents\n'
              '• One-time installation fee may apply\n'
              '• First month\'s bill will be generated after installation',
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        UIHelpers.customTextField(
          controller: _fullNameController,
          label: 'Full Name',
          validator: Validators.validateName,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        UIHelpers.customTextField(
          controller: _emailController,
          label: 'Email',
          validator: Validators.validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        UIHelpers.customTextField(
          controller: _phoneController,
          label: 'Phone Number',
          validator: Validators.validatePhone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        const Text(
          'Note: We will use this information to contact you regarding your application.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      children: [
        UIHelpers.customTextField(
          controller: _addressController,
          label: 'Installation Address',
          validator: _validateAddressField,
          maxLines: 3,
          hintText: 'Enter your complete address including city, state and PIN code',
        ),
        const SizedBox(height: 16),
        const Text(
          'Note: This address will be used for service installation. Please provide a complete and accurate address to avoid installation delays.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}