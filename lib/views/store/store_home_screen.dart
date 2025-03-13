// lib/screens/store/store_home_screen.dart
import 'package:flutter/material.dart';
import 'package:ispmanagement/utils/prodcut_card.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';


class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({Key? key}) : super(key: key);

  @override
  _StoreHomeScreenState createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  final ProductService _productService = ProductService();
  List<Product> _featuredProducts = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories and featured products in parallel
      final categoriesFuture = _productService.getCategories();
      final productsFuture = _productService.getProducts(featured: true);

      final categories = await categoriesFuture;
      final products = await productsFuture;

      setState(() {
        _categories = categories;
        // Assume productsFuture is already returning List<Product>
        _featuredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.pushNamed(context, '/store/orders');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.pushNamed(context, '/store/cart');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Banner
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.blue[700],
                child: const Center(
                  child: Text(
                    'Welcome to Our Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Quick Access Links
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAccessButton(
                      icon: Icons.category,
                      label: 'All Products',
                      onTap: () => Navigator.pushNamed(context, '/store/products'),
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.shopping_bag,
                      label: 'My Orders',
                      onTap: () => Navigator.pushNamed(context, '/store/orders'),
                    ),
                    _buildQuickAccessButton(
                      icon: Icons.shopping_cart,
                      label: 'Cart',
                      onTap: () => Navigator.pushNamed(context, '/store/cart'),
                    ),
                  ],
                ),
              ),

              // Categories Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/store/products',
                                arguments: {
                                  'categoryId': category['id'],
                                  'categoryName': category['name'],
                                },
                              );
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                      image: category['image'] != null
                                          ? DecorationImage(
                                        image: NetworkImage(category['image']),
                                        fit: BoxFit.cover,
                                      )
                                          : null,
                                    ),
                                    child: category['image'] == null
                                        ? const Icon(
                                      Icons.category,
                                      color: Colors.grey,
                                      size: 40,
                                    )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category['name'],
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Featured Products
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/store/products',
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _featuredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _featuredProducts[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar removed
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}