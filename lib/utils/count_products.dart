// Count Products and Categories in Firebase
// Run: flutter run lib/utils/count_products.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../utils/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CountProductsApp());
}

class CountProductsApp extends StatelessWidget {
  const CountProductsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CountScreen(),
    );
  }
}

class CountScreen extends StatefulWidget {
  const CountScreen({super.key});

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  bool isLoading = false;
  int totalProducts = 0;
  int totalCategories = 0;
  Map<String, int> productsByCategory = {};
  List<String> categoryNames = [];

  @override
  void initState() {
    super.initState();
    countData();
  }

  Future<void> countData() async {
    setState(() => isLoading = true);

    try {
      final db = FirebaseFirestore.instance;
      
      // Count Categories
      final categoriesSnapshot = await db.collection('Categories').get();
      totalCategories = categoriesSnapshot.docs.length;
      
      // Get category names
      for (var doc in categoriesSnapshot.docs) {
        final name = doc.data()['name'] as String? ?? doc.id;
        categoryNames.add(name);
        productsByCategory[name] = 0; // Initialize
      }
      
      TLoggerHelper.info('📁 Total Categories: $totalCategories');
      TLoggerHelper.info('Categories: ${categoryNames.join(", ")}');
      
      // Count Products
      final productsSnapshot = await db.collection('Products').get();
      totalProducts = productsSnapshot.docs.length;
      
      // Count products per category
      for (var doc in productsSnapshot.docs) {
        final categoryId = doc.data()['categoryId'] as String?;
        
        // Find matching category name
        String categoryName = 'Unknown';
        try {
          final category = categoriesSnapshot.docs.firstWhere(
            (cat) => cat.id == categoryId,
          );
          categoryName = category.data()['name'] as String? ?? categoryId ?? 'Unknown';
        } catch (e) {
          categoryName = categoryId ?? 'Unknown';
        }
        
        productsByCategory[categoryName] = (productsByCategory[categoryName] ?? 0) + 1;
      }
      
      TLoggerHelper.info('📦 Total Products: $totalProducts');
      
      // Sort by product count descending
      final sortedCategories = productsByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (var entry in sortedCategories) {
        TLoggerHelper.info('  • ${entry.key}: ${entry.value} products');
      }
      
      setState(() => isLoading = false);
      
    } catch (e) {
      TLoggerHelper.error('Error counting data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Count'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Inventory Count',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Total Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$totalCategories',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Categories',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.blue[200],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$totalProducts',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text(
                                  'Products',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Products per Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category breakdown
                  ...productsByCategory.entries.map((entry) {
                    final percentage = totalProducts > 0 
                        ? (entry.value / totalProducts * 100).toStringAsFixed(1)
                        : '0.0';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$percentage% of total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: countData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Count'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
