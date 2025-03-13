import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ispmanagement/models/billing_model.dart';
import 'package:ispmanagement/models/order_item.dart';
import 'package:ispmanagement/providers/connection_provider.dart';
import 'package:ispmanagement/providers/store_provider.dart';
import 'package:ispmanagement/views/complaints/complaints_list.dart';
import 'package:ispmanagement/views/connection/bill_payment.dart';
import 'package:ispmanagement/views/connection/connection_application.dart';
import 'package:ispmanagement/views/connection/connection_details.dart';
import 'package:ispmanagement/views/connection/connection_status.dart';
import 'package:ispmanagement/views/store/store_home_screen.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Placeholder pages for the bottom navigation
  final List<Widget> _pages = [
    const DashboardPage(),
    const ConnectionsPage(),
    const BillingPage(),
    const ProfilePage(),
  ];
@override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    connectionProvider.getActiveConnection();
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard page content
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
              _showNotificationsDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
          // You would typically refresh your data from the API here
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppConstants.primaryColor,
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome,',
                                style: AppConstants.bodyStyle,
                              ),
                              Text(
                                user?.firstName ?? 'User',
                                style: AppConstants.subheadingStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildActiveConnectionSection(context),
              const SizedBox(height: 20),

              Text(
                'Quick Actions',
                style: AppConstants.subheadingStyle,
              ),

              const SizedBox(height: 12),

              // Quick actions grid
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildQuickActionCard(
                    context,
                    title: 'Apply for Connection',
                    icon: Icons.add_link,
                    onTap: () {
                      // Navigate to apply for connection
                      _navigateToConnectionApplication(context);
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    title: 'Pay Bill',
                    icon: Icons.payment,
                    onTap: () {
                      // Navigate to billing page
                      _navigateToBillingPage(context);
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    title: 'Check Status',
                    icon: Icons.info_outline,
                    onTap: () {
                      // Navigate to check status
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConnectionStatusScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    title: 'Support',
                    icon: Icons.support_agent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComplaintsListScreen(),
                        ),
                      );

                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    title: 'Store',
                    icon: Icons.info_outline,
                    onTap: () {
                      // Navigate to check status
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreHomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),


              // Recent bills list (placeholder)
              _buildBillingHistorySection(context),

              const SizedBox(height: 20),


              Text(
                'Recent Orders',
                style: AppConstants.subheadingStyle,
              ),

              const SizedBox(height: 12),
              FutureBuilder<List<Order>>(
                future: Provider.of<StoreProvider>(context, listen: false).fetchOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error loading orders: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No recent orders',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StoreHomeScreen(),
                                  ),
                                );
                              },
                              child: const Text('Shop Now'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Show most recent 3 orders
                    final orders = snapshot.data!;
                    final recentOrders = orders.length > 3 ? orders.sublist(0, 3) : orders;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Column(
                        children: [
                          ...recentOrders.map((order) => Column(
                            children: [
                              ListTile(
                                title: Text('Order #${order.orderNumber}'),
                                subtitle: Text('${DateFormat('MMM dd, yyyy').format(order.createdAt)}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${order.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        order.statusDisplay,
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/store/order-details',
                                    arguments: order.id,
                                  );
                                },
                              ),
                              if (order != recentOrders.last) const Divider(height: 1),
                            ],
                          )).toList(),
                          const Divider(height: 1),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/store/orders');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'View All Orders',
                                    style: TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: AppConstants.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),


              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildActiveConnectionSection(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, connectionProvider, child) {
        // Check if there's an active connection
        final activeConnection = connectionProvider.activeConnection;

        if (activeConnection == null) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Connection Status',
                        style: AppConstants.subheadingStyle,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NO CONNECTION',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.wifi_off,
                          color: AppConstants.primaryColor,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Active Connection',
                              style: AppConstants.subheadingStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Apply for a new connection to get started',
                              style: AppConstants.bodyStyle.copyWith(
                                color: AppConstants.lightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  UIHelpers.primaryButton(
                    text: 'Apply for Connection',
                    onPressed: () {
                      _navigateToConnectionApplication(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        // Display the active connection
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Connection',
                      style: AppConstants.subheadingStyle,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(activeConnection.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activeConnection.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(activeConnection.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildConnectionDetailRow(
                  'Package',
                  activeConnection.package?.name ?? activeConnection.packageName ?? 'N/A',
                ),
                _buildConnectionDetailRow(
                  'Speed',
                  activeConnection.package?.speed ?? 'Standard Speed',
                ),
                _buildConnectionDetailRow(
                  'Connection Number',
                  activeConnection.connectionNumber ?? activeConnection.id?.toString() ?? 'Pending Assignment',
                ),
                _buildConnectionDetailRow(
                  'Activated On',
                  activeConnection.createdAt != null
                      ? _formatDate(activeConnection.createdAt!)
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                UIHelpers.primaryButton(
                  text: 'View Details',
                  onPressed: () {
                    // Navigate to connection details screen
                    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                    if (homeScreenState != null) {
                      homeScreenState.setState(() {
                        homeScreenState._currentIndex = 1; // Connections page
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Add these helper methods if they don't already exist in the class
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'installation_scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConnectionDetailRow(String label, dynamic value) {
    // Convert the value to a String regardless of its type
    String displayValue;

    if (value == null) {
      displayValue = 'N/A';
    } else if (value is String) {
      displayValue = value;
    } else if (value is int || value is double) {
      displayValue = value.toString();
    } else if (value is bool) {
      displayValue = value ? 'Yes' : 'No';
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            displayValue,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
// Add this method in the DashboardPage class
  Widget _buildBillingHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Billing History',
              style: AppConstants.subheadingStyle,
            ),
            TextButton(
              onPressed: () {
                // Switch to billing tab
                final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                if (homeScreenState != null) {
                  homeScreenState.setState(() {
                    homeScreenState._currentIndex = 2;
                  });
                }
              },
              child: Text(
                'View All',
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            // Use the existing billingHistoryResponse
            final billingHistoryResponse = connectionProvider.billingHistoryResponse;

            // Check loading state
            if (billingHistoryResponse.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check for errors
            if (billingHistoryResponse.isError) {
              return Text(
                'Error loading billing history: ${billingHistoryResponse.message}',
                style: TextStyle(color: Colors.red),
              );
            }

            // Get the billing history
            final bills = billingHistoryResponse.data ?? [];

            // Handle empty state
            if (bills.isEmpty) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No Billing History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                          if (homeScreenState != null) {
                            homeScreenState.setState(() {
                              homeScreenState._currentIndex = 2;
                            });
                          }
                        },
                        child: const Text('View Billing'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show most recent 3 bills
            final recentBills = bills.length > 3 ? bills.sublist(0, 3) : bills;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                children: [
                  ...recentBills.map((bill) => Column(
                    children: [
                      ListTile(
                        title: Text('Bill #${bill.id}'),
                        subtitle: Text(bill.billingPeriod),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bill.formattedBillAmount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getBillingStatusColor(bill.paymentStatus).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                bill.paymentStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _getBillingStatusColor(bill.paymentStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showBillDetails(context, bill);
                        },
                      ),
                      if (bill != recentBills.last) const Divider(height: 1),
                    ],
                  )).toList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

// Helper methods to be added in the same class
  Color _getBillingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBillDetails(BuildContext context, MonthlyBilling bill) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill Details',
                  style: AppConstants.subheadingStyle,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildBillingInfoRow('Bill Number', '#${bill.id}'),
            _buildBillingInfoRow('Billing Period', bill.billingPeriod),
            _buildBillingInfoRow('Due Date', bill.formattedDueDate),
            _buildBillingInfoRow('Amount', bill.formattedBillAmount),
            _buildBillingInfoRow('Status', bill.paymentStatus.toUpperCase()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

// Add this method to handle bill details


// Add this method to get billing status color

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppConstants.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppConstants.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkStatusItem(
      String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppConstants.bodyStyle,
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: AppConstants.bodyStyle.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToConnectionApplication(BuildContext context) {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    // Show package selection bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder(
          future: connectionProvider.getPackages(),
          builder: (context, snapshot) {
            if (connectionProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (connectionProvider.packagesResponse.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load packages',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      connectionProvider.packagesResponse.message ??
                          'Please try again later',
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final packages = connectionProvider.packages;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select a Package',
                        style: AppConstants.subheadingStyle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final isRecommended =
                          index == 1; // Recommend the middle package

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isRecommended
                              ? BorderSide(
                                  color: AppConstants.primaryColor, width: 2)
                              : BorderSide.none,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isRecommended)
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                ),
                                child: const Text(
                                  'RECOMMENDED',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    package.name,
                                    style: AppConstants.subheadingStyle,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    package.speed.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rs. ${package.price.toStringAsFixed(0)}/month',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppConstants.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Features:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          8), // Show package description as a feature
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(package.description),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Show speed as a feature
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                              'Download speed up to ${package.speed}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Add more generic features
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text('Unlimited data'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text('24/7 technical support'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  UIHelpers.primaryButton(
                                    text: 'Select Plan',
                                    onPressed: () {
                                      // Set the selected package and navigate to application form
                                      connectionProvider
                                          .setSelectedPackage(package);
                                      Navigator.of(context).pop();

                                      // Navigate to application form
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ConnectionApplicationForm(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToBillingPage(BuildContext context) {
    // Switch to billing tab
    (context.findAncestorStateOfType<_HomeScreenState>())?.setState(() {
      (context.findAncestorStateOfType<_HomeScreenState>())?._currentIndex = 2;
    });
  }

  void _navigateToApplicationStatus(BuildContext context) {
    UIHelpers.showToast(message: 'Application status coming soon!');
  }

  void _navigateToSupport(BuildContext context) {
    UIHelpers.showToast(message: 'Support page coming soon!');
  }

  void _navigateToBillingHistory(BuildContext context) {
    // Switch to billing tab
    (context.findAncestorStateOfType<_HomeScreenState>())?.setState(() {
      (context.findAncestorStateOfType<_HomeScreenState>())?._currentIndex = 2;
    });
  }

  void _navigateToBillDetails(BuildContext context, int billId) {
    UIHelpers.showToast(message: 'Bill details for #$billId coming soon!');
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: const [
              ListTile(
                title: Text('Your bill is due'),
                subtitle:
                    Text('Please pay your monthly bill before the due date.'),
                leading: Icon(Icons.notifications_active, color: Colors.red),
              ),
              ListTile(
                title: Text('Network maintenance'),
                subtitle: Text(
                    'Scheduled maintenance on June 10, 2023, from 2 AM to 4 AM.'),
                leading: Icon(Icons.build, color: Colors.orange),
              ),
              ListTile(
                title: Text('Welcome to ISP Management'),
                subtitle: Text('Thank you for joining our service!'),
                leading: Icon(Icons.celebration, color: Colors.green),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} // Connections page content


class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({Key? key}) : super(key: key);

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch active connection when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      await provider.getActiveConnection();
      _debugConnection();
    });
  }

  // Debug method to help identify issues
  void _debugConnection() {
    final provider = Provider.of<ConnectionProvider>(context, listen: false);

    print("\n=== CONNECTION DEBUG ===");
    print("Active Connection Response Status: ${provider.activeConnectionResponse.status}");

    if (provider.activeConnectionResponse.isError) {
      print("Error Message: ${provider.activeConnectionResponse.message}");
    }

    if (provider.activeConnection != null) {
      final conn = provider.activeConnection!;
      print("Connection ID: ${conn.id}");
      print("Status: ${conn.status}");
      print("Package ID: ${conn.packageId}");
      print("Package Name: ${conn.packageName}");
      print("Connection Number: ${conn.connectionNumber}");

      if (conn.package != null) {
        print("Package Object:");
        print(" - Name: ${conn.package!.name}");
        print(" - Speed: ${conn.package!.speed}");
      } else {
        print("Package Object: NULL");
      }
    } else {
      print("Active Connection: NULL");
    }
    print("=======================\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Connections'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ConnectionProvider>(context, listen: false).getActiveConnection();
              _debugConnection();
            },
          ),
        ],
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          // Show loading indicator while fetching connection
          if (connectionProvider.activeConnectionResponse.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check for errors
          if (connectionProvider.activeConnectionResponse.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load connection',
                    style: AppConstants.subheadingStyle,
                  ),
                  Text(
                    connectionProvider.activeConnectionResponse.message ?? 'Unknown error',
                    style: AppConstants.bodyStyle.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      connectionProvider.getActiveConnection();
                      _debugConnection();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Check if there's an active connection
          final activeConnection = connectionProvider.activeConnection;
          if (activeConnection == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Connections',
                    style: AppConstants.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Apply for a new connection to get started',
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  UIHelpers.primaryButton(
                    text: 'Apply for Connection',
                    onPressed: () {
                      _navigateToConnectionApplication(context);
                    },
                    isFullWidth: false,
                  ),
                ],
              ),
            );
          }

          // Display the active connection
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active Connection',
                                style: AppConstants.subheadingStyle,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(activeConnection.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activeConnection.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(activeConnection.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildConnectionDetailRow(
                            'Package',
                            activeConnection.package?.name ?? activeConnection.packageName ?? 'N/A',
                          ),
                          _buildConnectionDetailRow(
                            'Speed',
                            activeConnection.package?.speed ?? 'Standard Speed',
                          ),
                          _buildConnectionDetailRow(
                            'Connection Number',
                            activeConnection.connectionNumber ?? activeConnection.id?.toString() ?? 'Pending Assignment',
                          ),
                          _buildConnectionDetailRow(
                            'Activated On',
                            activeConnection.createdAt != null
                                ? _formatDate(activeConnection.createdAt!)
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  UIHelpers.primaryButton(
                    text: 'View Details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectionDetailsScreen(
                            applicationId: activeConnection.id!,

                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _navigateToConnectionApplication(context);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'installation_scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

// Replace your current _buildConnectionDetailRow method with this safer version
  Widget _buildConnectionDetailRow(String label, dynamic value) {
    // Convert the value to a String regardless of its type
    String displayValue;

    if (value == null) {
      displayValue = 'N/A';
    } else if (value is String) {
      displayValue = value;
    } else if (value is int || value is double) {
      displayValue = value.toString();
    } else if (value is bool) {
      displayValue = value ? 'Yes' : 'No';
    } else {
      displayValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            displayValue,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToConnectionApplication(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ConnectionApplicationScreen(),
    //   ),
    // );
  }
}

// Billing page content


class BillingPage extends StatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch billing data
      final provider = Provider.of<ConnectionProvider>(context, listen: false);
      provider.getCurrentBilling();
      provider.getBillingHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: AppConstants.primaryColor,
        bottom: TabBar(
          unselectedLabelColor: Colors.black,
          labelColor: Colors.white,
         indicatorColor: Colors.red,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Bill'),
            Tab(text: 'Billing History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrentBillTab(),
          _buildBillingHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCurrentBillTab() {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, child) {
        if (provider.currentBillingResponse.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.currentBillingResponse.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load current billing',
                  style: AppConstants.subheadingStyle,
                ),
                Text(
                  provider.currentBillingResponse.message ?? 'Unknown error',
                  style: AppConstants.bodyStyle.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.getCurrentBilling();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final currentBilling = provider.currentBilling;
        if (currentBilling == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Current Bill',
                  style: AppConstants.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'You don\'t have any current billing information.',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.lightTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate days until due date
        final daysRemaining = currentBilling.daysUntilNextBilling ?? 0;
        final isOverdue = daysRemaining < 0;

        // Display current billing information
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Bill',
                              style: AppConstants.subheadingStyle,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBillingStatusColor(currentBilling.paymentStatus).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentBilling.isPaid
                                    ? 'Paid'
                                    : (isOverdue ? 'Overdue' : 'Due in $daysRemaining days'),
                                style: TextStyle(
                                  color: _getBillingStatusColor(currentBilling.paymentStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currentBilling.formattedBillAmount,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Due date: ${currentBilling.formattedDueDate}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.lightTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildBillingInfoRow('Billing Period', currentBilling.billingPeriod),
                        _buildBillingInfoRow('Package', currentBilling.packageInfo?['name'] ?? 'N/A'),
                        if (currentBilling.isPaid)
                          _buildBillingInfoRow('Payment Date', _formatDate(currentBilling.paymentDate)),
                        if (currentBilling.isPaid && currentBilling.transactionId != null)
                          _buildBillingInfoRow('Transaction ID', currentBilling.transactionId!),
                        const SizedBox(height: 16),
                        if (!currentBilling.isPaid)
                          UIHelpers.primaryButton(
                            text: 'Pay Now',
                            onPressed: () {
                              _showPaymentOptions(context, currentBilling);
                            },
                          ),
                        if (currentBilling.isPaid)
                          OutlinedButton(
                            onPressed: () {
                              UIHelpers.showToast(message: 'Download receipt feature coming soon!');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                              minimumSize: const Size(double.infinity, 48),
                              side: BorderSide(color: AppConstants.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Download Receipt'),
                          ),
                      ],
                    ),
                  ),
                ),

                if (currentBilling.packageInfo != null && currentBilling.packageInfo!['features'] != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Package Details',
                    style: AppConstants.subheadingStyle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBillingInfoRow('Package', currentBilling.packageInfo?['name'] ?? 'N/A'),
                          _buildBillingInfoRow('Speed', currentBilling.packageInfo?['speed'] ?? 'N/A'),
                          const SizedBox(height: 12),
                          const Text(
                            'Features:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._buildFeaturesList(currentBilling.packageInfo?['features']),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingHistoryTab() {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, child) {
        if (provider.billingHistoryResponse.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.billingHistoryResponse.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load billing history',
                  style: AppConstants.subheadingStyle,
                ),
                Text(
                  provider.billingHistoryResponse.message ?? 'Unknown error',
                  style: AppConstants.bodyStyle.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.getBillingHistory();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final billingHistory = provider.billingHistory;
        if (billingHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Billing History',
                  style: AppConstants.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your billing history will appear here once you have bills.',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.lightTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: billingHistory.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final bill = billingHistory[index];
            return ListTile(
              title: Text('Bill #${bill.id}'),
              subtitle: Text('Period: ${bill.billingPeriod}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bill.formattedBillAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getBillingStatusColor(bill.paymentStatus).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bill.paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getBillingStatusColor(bill.paymentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                _showBillDetails(context, bill);
              },
            );
          },
        );
      },
    );
  }

  Color _getBillingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBillingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeaturesList(List<dynamic>? features) {
    if (features == null || features.isEmpty) {
      return [const Text('No features available')];
    }

    return features.map((feature) {
      return Padding(
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
              child: Text(feature.toString()),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  void _showPaymentOptions(BuildContext context, MonthlyBilling bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... existing code ...
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_android, color: Colors.purple),
              ),
              title: const Text('Razorpay'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop(); // Close bottom sheet

                // Navigate to BillPaymentScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BillPaymentScreen(bill: bill),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _processCreditCardPayment(BuildContext context, MonthlyBilling bill) {
    _showPaymentForm(context, 'Credit Card', bill);
  }

  void _processNetBankingPayment(BuildContext context, MonthlyBilling bill) {
    _showPaymentForm(context, 'Net Banking', bill);
  }

  void _processUpiPayment(BuildContext context, MonthlyBilling bill) {
    _showPaymentForm(context, 'UPI', bill);
  }

  void _showPaymentForm(BuildContext context, String method, MonthlyBilling bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay via $method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: ${bill.formattedBillAmount}'),
            const SizedBox(height: 16),
            if (method == 'Credit Card') ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        border: OutlineInputBorder(),
                        hintText: 'MM/YY',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ] else if (method == 'Net Banking') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'sbi', child: Text('State Bank of India')),
                  DropdownMenuItem(value: 'hdfc', child: Text('HDFC Bank')),
                  DropdownMenuItem(value: 'icici', child: Text('ICICI Bank')),
                  DropdownMenuItem(value: 'axis', child: Text('Axis Bank')),
                ],
                onChanged: (value) {},
              ),
            ] else if (method == 'UPI') ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  border: OutlineInputBorder(),
                  hintText: 'username@upi',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmPayment(context, bill);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _confirmPayment(BuildContext context, MonthlyBilling bill) {
    if (bill.id == null) {
      UIHelpers.showToast(message: 'Cannot process payment. Bill ID is missing.');
      return;
    }

    // In a real app, you would integrate with a payment gateway here
    // For this example, we'll simulate a successful payment

    // Mock payment details
    final paymentDetails = {
      'payment_id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
      'order_id': 'ORD${DateTime.now().millisecondsSinceEpoch}',
      'signature': 'SIG${DateTime.now().millisecondsSinceEpoch}',
    };

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    // Process the payment through the provider
    final provider = Provider.of<ConnectionProvider>(context, listen: false);
    provider.confirmPayment(bill.id!, paymentDetails).then((success) {
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        _showPaymentSuccess(context, paymentDetails['payment_id']!);
      } else {
        UIHelpers.showToast(message: 'Payment failed. Please try again.');
      }
    });
  }

  void _showPaymentSuccess(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your payment has been successfully processed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Transaction ID: $transactionId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Refresh the data
              final provider = Provider.of<ConnectionProvider>(context, listen: false);
              provider.getCurrentBilling();
              provider.getBillingHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBillDetails(BuildContext context, MonthlyBilling bill) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill Details',
                  style: AppConstants.subheadingStyle,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildBillingInfoRow('Bill Number', '#${bill.id}'),
            _buildBillingInfoRow('Billing Period', bill.billingPeriod),
            _buildBillingInfoRow('Due Date', bill.formattedDueDate),
            _buildBillingInfoRow('Amount', bill.formattedBillAmount),
            _buildBillingInfoRow('Status', bill.paymentStatus.toUpperCase()),
            if (bill.isPaid && bill.paymentDate != null)
              _buildBillingInfoRow('Payment Date', _formatDate(bill.paymentDate)),
            if (bill.isPaid && bill.transactionId != null)
              _buildBillingInfoRow('Transaction ID', bill.transactionId!),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Package Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBillingInfoRow('Package', bill.packageInfo?['name'] ?? 'N/A'),
            _buildBillingInfoRow('Speed', bill.packageInfo?['speed'] ?? 'N/A'),
            const SizedBox(height: 16),
            if (bill.isPending)
              UIHelpers.primaryButton(
                text: 'Pay Now',
                onPressed: () {
                  Navigator.of(context).pop();
                  _showPaymentOptions(context, bill);
                },
              ),
            if (bill.isPaid)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  UIHelpers.showToast(
                      message: 'Download receipt feature coming soon!');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: AppConstants.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Download Receipt'),
              ),
          ],
        ),
      ),
    );
  }
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          children: [
            // Profile header
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        user != null
                            ? user.firstName[0] + user.lastName[0]
                            : 'U',
                        style:
                            const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'
                          : 'User',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@example.com',
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          onPressed: () {
                            _navigateToEditProfile(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.primaryColor,
                            side: BorderSide(color: AppConstants.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile options
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    onTap: () {
                      _navigateToPersonalInfo(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'Change Password',
                    icon: Icons.lock_outline,
                    onTap: () {
                      _navigateToChangePassword(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'Notifications',
                    icon: Icons.notifications_none,
                    onTap: () {
                      _navigateToNotificationSettings(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'Payment Methods',
                    icon: Icons.credit_card,
                    onTap: () {
                      _navigateToPaymentMethods(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Support options
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    onTap: () {
                      _navigateToHelpSupport(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      _navigateToPrivacyPolicy(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'Terms & Conditions',
                    icon: Icons.description_outlined,
                    onTap: () {
                      _navigateToTermsConditions(context);
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    context,
                    title: 'About',
                    icon: Icons.info_outline,
                    onTap: () {
                      _navigateToAbout(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout option
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    title: 'Logout',
                    icon: Icons.logout,
                    onTap: () async {
                      final confirm = await UIHelpers.showConfirmationDialog(
                        context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                      );

                      if (confirm) {
                        await authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    textColor: AppConstants.errorColor,
                    iconColor: AppConstants.errorColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // App version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppConstants.lightTextColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppConstants.textColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // Navigation methods
  void _navigateToEditProfile(BuildContext context) {
    _showComingSoonDialog(context, 'Edit Profile');
  }

  void _navigateToPersonalInfo(BuildContext context) {
    _showComingSoonDialog(context, 'Personal Information');
  }

  void _navigateToChangePassword(BuildContext context) {
    _showChangePasswordDialog(context);
  }

  void _navigateToNotificationSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Notification Settings');
  }

  void _navigateToPaymentMethods(BuildContext context) {
    _showComingSoonDialog(context, 'Payment Methods');
  }

  void _navigateToHelpSupport(BuildContext context) {
    _showHelpSupportDialog(context);
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    _showComingSoonDialog(context, 'Privacy Policy');
  }

  void _navigateToTermsConditions(BuildContext context) {
    _showComingSoonDialog(context, 'Terms & Conditions');
  }

  void _navigateToAbout(BuildContext context) {
    _showAboutDialog(context);
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.engineering,
              size: 50,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 16),
            Text(
              '$feature is coming soon!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We are working on this feature and it will be available in the next update.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              UIHelpers.showToast(message: 'Password changed successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.support_agent,
              size: 50,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+91 1234567890',
              onTap: () {
                Navigator.of(context).pop();
                UIHelpers.showToast(message: 'Calling feature coming soon!');
              },
            ),
            const SizedBox(height: 8),
            _buildSupportOption(
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'support@ispmanagement.com',
              onTap: () {
                Navigator.of(context).pop();
                UIHelpers.showToast(message: 'Email feature coming soon!');
              },
            ),
            const SizedBox(height: 8),
            _buildSupportOption(
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Available 24/7',
              onTap: () {
                Navigator.of(context).pop();
                UIHelpers.showToast(message: 'Live chat feature coming soon!');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppConstants.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(
                Icons.wifi,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ISP Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'ISP Management is a comprehensive solution for Internet Service Providers to manage their customers, connections, and billing.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2023 ISP Management, Inc.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
