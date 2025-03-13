class ApiEndpoints {
  // Base URL for local development
  // Use 10.0.2.2 instead of localhost for Android emulator
  // Use localhost:8000 for iOS simulator
  static const String baseUrl = 'http://localhost:8000/'; // Has trailing slash

  // Auth endpoints
  static const String register = 'api/users/register/'; // No leading slash
  static const String login = 'api/users/login/'; // No leading slash

  // Connection endpoints
  static const String connections = 'api/connections/user/connections/';
  static const String uploadDocument = 'api/connections/user/connections/{id}/upload_document/';
  static const String activeConnection = 'api/connections/user/active-connection/';
  static const String userConnectionApplication = 'api/connections/user/connection-application/'; // New endpoint

  // Billing endpoints
  static const String billing = 'api/connections/billing/';
  static const String currentBilling = 'api/connections/billing/current/';
  static const String confirmPayment = 'api/connections/billing/{id}/confirm-payment/';

  // Package endpoints
  static const String packages = 'api/packages/'; // List all active packages
  static const String subscribePackage = 'api/packages/subscribe/{id}/'; // Subscribe to a package
  static const String userSubscriptions = 'api/packages/subscriptions/'; // User's subscriptions
  static const String currentSubscription = 'api/packages/subscriptions/current/'; // User's current subscription
  static const String cancelSubscription = 'api/packages/subscriptions/{id}/cancel/'; // Cancel a subscription
  static const String complaints = 'api/complaints/user/complaints/';
  static const String complaintComments = 'api/complaints/user/complaints/{id}/add_comment/';

  static const String closeComplaint = 'api/complaints/user/complaints/{id}/close_complaint/';

  // Helper method to get full URL
  static String getUrl(String endpoint) {
    // Check if endpoint already starts with baseUrl
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return baseUrl + endpoint;
  }

  // Helper method to replace path parameters in URL
  static String getUrlWithPathParam(String endpoint, String paramName, String paramValue) {
    // Remove leading slash from endpoint if present
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return baseUrl + cleanEndpoint.replaceAll('{$paramName}', paramValue);
  }
}