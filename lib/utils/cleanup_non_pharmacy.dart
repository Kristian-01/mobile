// Cleanup Script: Delete ALL non-pharmacy products and categories from Firebase
// Run: flutter run lib/utils/cleanup_non_pharmacy.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../utils/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CleanupNonPharmacyApp());
}

class CleanupNonPharmacyApp extends StatelessWidget {
  const CleanupNonPharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CleanupScreen(),
    );
  }
}

class CleanupScreen extends StatefulWidget {
  const CleanupScreen({super.key});

  @override
  State<CleanupScreen> createState() => _CleanupScreenState();
}

class _CleanupScreenState extends State<CleanupScreen> {
  bool isProcessing = false;
  String statusMessage = 'Ready to clean up non-pharmacy data';
  int deletedProducts = 0;
  int deletedCategories = 0;
  int remainingProducts = 0;
  int remainingCategories = 0;

  bool _isPharmacyCategory(String? categoryId) {
    final s = (categoryId ?? '').toLowerCase();
    if (s.isEmpty) return false;
    
    // ❌ EXCLUDE these
    if (s.contains('food') || 
        s.contains('beverage') || 
        s.contains('snack') || 
        s.contains('household') || 
        s.contains('others') || 
        s.contains('other')) {
      return false;
    }
    
    // ✅ ALLOW only these pharmacy categories
    const allowedCategories = [
      'baby_products',
      'baby products',
      'feminine_care',
      'feminine care',
      'female_care',
      'female care',
      'medicines',
      'medicine',
      'medical_supplies',
      'medical supplies',
      'personal_care',
      'personal care',
    ];
    
    return allowedCategories.any((pharma) => s.contains(pharma));
  }

  Future<void> cleanupNonPharmacyData() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Starting cleanup...';
      deletedProducts = 0;
      deletedCategories = 0;
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // ========== STEP 1: Delete Non-Pharmacy Products ==========
      setState(() => statusMessage = '🗑️ Scanning products...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final productsSnapshot = await db.collection('Products').get();
      TLoggerHelper.info('📦 Total products in Firebase: ${productsSnapshot.docs.length}');
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final categoryId = data['categoryId'] as String?;
        final productName = data['title'] as String? ?? 'Unknown';
        
        // Delete if NOT a pharmacy category
        if (!_isPharmacyCategory(categoryId)) {
          await doc.reference.delete();
          deletedProducts++;
          TLoggerHelper.warning('❌ Deleted: $productName (Category: $categoryId)');
          
          if (deletedProducts % 50 == 0) {
            setState(() {
              statusMessage = '🗑️ Deleted $deletedProducts non-pharmacy products...';
            });
          }
        }
      }
      
      // ========== STEP 2: Delete Non-Pharmacy Categories ==========
      setState(() => statusMessage = '🗑️ Scanning categories...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final categoriesSnapshot = await db.collection('Categories').get();
      TLoggerHelper.info('📁 Total categories in Firebase: ${categoriesSnapshot.docs.length}');
      
      final allowedCategoryIds = [
        'baby_products',
        'feminine_care',
        'medicines',
        'medical_supplies',
        'personal_care',
      ];
      
      for (var doc in categoriesSnapshot.docs) {
        final categoryId = doc.id;
        final categoryName = doc.data()['name'] as String? ?? 'Unknown';
        
        // Delete if NOT in allowed list
        if (!allowedCategoryIds.contains(categoryId)) {
          await doc.reference.delete();
          deletedCategories++;
          TLoggerHelper.warning('❌ Deleted Category: $categoryName ($categoryId)');
        }
      }
      
      // ========== STEP 3: Count Remaining Items ==========
      setState(() => statusMessage = '📊 Counting remaining items...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final remainingProductsSnapshot = await db.collection('Products').get();
      remainingProducts = remainingProductsSnapshot.docs.length;
      
      final remainingCategoriesSnapshot = await db.collection('Categories').get();
      remainingCategories = remainingCategoriesSnapshot.docs.length;
      
      TLoggerHelper.info('✅ CLEANUP COMPLETE!');
      TLoggerHelper.info('📦 Products: ${productsSnapshot.docs.length} → $remainingProducts (Deleted: $deletedProducts)');
      TLoggerHelper.info('📁 Categories: ${categoriesSnapshot.docs.length} → $remainingCategories (Deleted: $deletedCategories)');
      
      setState(() {
        statusMessage = '✅ CLEANUP COMPLETE!';
        isProcessing = false;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Cleanup Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🗑️ Deleted Products: $deletedProducts'),
                Text('🗑️ Deleted Categories: $deletedCategories'),
                const SizedBox(height: 16),
                Text('📦 Remaining Products: $remainingProducts', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('📁 Remaining Categories: $remainingCategories', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      TLoggerHelper.error('Error during cleanup: $e');
      setState(() {
        statusMessage = '❌ Error: $e';
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleanup Non-Pharmacy Data'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.delete_forever,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Delete Non-Pharmacy Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 16,
                color: isProcessing ? Colors.orange : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isProcessing && deletedProducts > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text('🗑️ Deleted: $deletedProducts products, $deletedCategories categories'),
                    const SizedBox(height: 8),
                    Text('📦 Remaining: $remainingProducts products', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('📁 Remaining: $remainingCategories categories', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isProcessing ? null : cleanupNonPharmacyData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Processing...'),
                      ],
                    )
                  : const Text(
                      'START CLEANUP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will delete:\n'
              '❌ All food & beverage products\n'
              '❌ All household items\n'
              '❌ All "Others" category items\n'
              '❌ Non-pharmacy categories\n\n'
              '✅ Keep only:\n'
              '• Baby Products\n'
              '• Feminine Care\n'
              '• Medicines\n'
              '• Medical Supplies\n'
              '• Personal Care',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
