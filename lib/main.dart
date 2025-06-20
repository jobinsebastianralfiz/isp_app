import 'package:flutter/material.dart';
import 'package:ispmanagement/providers/complaint_provider.dart';
import 'package:ispmanagement/views/connection/connection_application.dart';
import 'package:ispmanagement/views/connection/connection_details.dart';
import 'package:ispmanagement/views/debug_api.dart';
import 'package:ispmanagement/views/splash/splash_view.dart';
import 'package:provider/provider.dart';
import 'config/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/connection_provider.dart';
import 'providers/package_provider.dart';
import 'providers/store_provider.dart';

// Import the store screens
import 'views/store/store_home_screen.dart';
import 'views/store/product_list_screen.dart';
import 'views/store/product_detail_screen.dart';
import 'views/store/cart_screen.dart';
import 'views/store/checkout_screen.dart';
import 'views/store/order_success_screen.dart';
import 'views/store/orders_screen.dart';
import 'views/store/order_detail_screen.dart';

import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => PackageProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()), // Add the StoreProvider
        Provider(create: (_) => DashboardPage()), // Provide DashboardPage for navigation from other tabs
      ],
      child: MaterialApp(
        title: 'ISP Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppConstants.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            primary: AppConstants.primaryColor,
            secondary: AppConstants.accentColor,
            error: AppConstants.errorColor,
          ),
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppConstants.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppConstants.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppConstants.errorColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 2,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Handle dynamic routes
          if (settings.name?.startsWith('/connection_details/') ?? false) {
            // Extract the connection ID from the route
            final connectionId = int.parse(settings.name!.split('/').last);
            return MaterialPageRoute(
              builder: (context) => ConnectionDetailsScreen(applicationId: connectionId),
            );
          }

          // Handle store routes with parameters
          if (settings.name == '/store/products') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ProductListScreen(
                categoryId: args?['categoryId'],
                categoryName: args?['categoryName'],
              ),
            );
          }

          if (settings.name == '/store/product-detail') {
            final productId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: productId),
            );
          }

          if (settings.name == '/store/order-success') {
            final orderId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(orderId: orderId),
            );
          }

          if (settings.name == '/store/order-details') {
            final orderId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: orderId),
            );
          }

          // Add this new route for accessing orders through the my-orders screen
          if (settings.name == '/store/my-orders') {
            return MaterialPageRoute(
              builder: (context) => const OrdersScreen(),
            );
          }

          return null;
        },
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/connection_application': (context) => const ConnectionApplicationForm(),
          '/debug': (context) => const DebugApiScreen(), // Debug screen route

          // Store routes
          '/store': (context) => const StoreHomeScreen(),
          '/store/cart': (context) => const CartScreen(),
          '/store/checkout': (context) => const CheckoutScreen(),
          '/store/orders': (context) => const OrdersScreen(),
        },
      ),
    );
  }
}