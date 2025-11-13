// Audit and Fix Product Categories - Remove Mismatched Products
// Run: flutter run lib/utils/audit_fix_categories.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../utils/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AuditCategoriesApp());
}

class AuditCategoriesApp extends StatelessWidget {
  const AuditCategoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuditScreen(),
    );
  }
}

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  bool isProcessing = false;
  String statusMessage = 'Ready to audit categories';
  List<Map<String, dynamic>> mismatchedProducts = [];
  int totalChecked = 0;
  
  // Define what products belong in each pharmacy category
  final Map<String, List<String>> categoryKeywords = {
    'medicines': [
      'tablet', 'capsule', 'syrup', 'suspension', 'drops',
      'biogesic', 'bioflu', 'neozep', 'decolgen', 'tuseran',
      'alaxan', 'medicol', 'paracetamol', 'ibuprofen', 'mefenamic',
      'ascof', 'solmux', 'robitussin', 'bactidol', 'kremil',
      'diatabs', 'imodium', 'buscopan', 'dulcolax',
      'cetirizine', 'loratadine', 'antihistamine', 'antibiotic',
      'amoxicillin', 'azithromycin', 'medicine', 'mg', 'ml'
    ],
    'baby_products': [
      'baby', 'infant', 'diaper', 'wipes', 'milk', 'formula',
      'lactum', 'bonakid', 'bonna', 'enfamil', 'similac',
      'ceelin', 'cherifer', 'erceflora', 'pacifier', 'bottle'
    ],
    'personal_care': [
      'soap', 'shampoo', 'toothpaste', 'toothbrush', 'cologne',
      'lotion', 'deodorant', 'powder', 'facial', 'cotton buds',
      'safeguard', 'dove', 'colgate', 'palmolive', 'johnson'
    ],
    'medical_supplies': [
      'alcohol', 'betadine', 'gauze', 'bandage', 'cotton',
      'mask', 'gloves', 'thermometer', 'syringe', 'nebulizer',
      'blood pressure', 'glucose', 'strip', 'test'
    ],
    'feminine_care': [
      'napkin', 'pad', 'pantyliner', 'sanitary', 'tampon',
      'modess', 'whisper', 'kotex', 'always', 'carefree',
      'lady pills', 'trust pills', 'althea', 'contraceptive'
    ],
  };
  
  // Food/Household items that should NOT be in pharmacy categories
  final List<String> nonPharmacyKeywords = [
    // Food & Beverages
    'tuna', 'sardines', 'corned beef', 'meat loaf', 'evap', 'evaporated milk',
    'alpine', 'alaska milk', 'bear brand', 'nescafe', 'coffee', 'milo',
    'juice', 'softdrinks', 'coke', 'sprite', 'pepsi', 'royal',
    'biscuit', 'cookie', 'cracker', 'wafer', 'candy', 'chocolate',
    'chips', 'snack', 'junk food', 'noodles', 'pasta', 'rice',
    'sugar', 'salt', 'oil', 'vinegar', 'soy sauce', 'ketchup',
    
    // Household Items
    'detergent', 'fabric conditioner', 'surf', 'tide', 'ariel',
    'bleach', 'zonrox', 'dishwashing', 'cleaner', 'wax',
    'tissue', 'toilet paper', 'napkins paper', 'air freshener',
    'insecticide', 'mosquito', 'cockroach', 'rat poison'
  ];

  Future<void> auditCategories() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Fetching all products...';
      mismatchedProducts.clear();
      totalChecked = 0;
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Get all products
      final productsSnapshot = await db.collection('Products').get();
      totalChecked = productsSnapshot.docs.length;
      
      TLoggerHelper.info('📦 Checking ${totalChecked} products...');
      setState(() => statusMessage = 'Analyzing products...');
      
      // Get all categories for reference
      final categoriesSnapshot = await db.collection('Categories').get();
      final categoriesMap = {
        for (var doc in categoriesSnapshot.docs)
          doc.id: doc.data()['name'] as String? ?? 'Unknown'
      };
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final productTitle = (data['title'] as String? ?? '').toLowerCase();
        final categoryId = (data['categoryId'] as String? ?? '').toLowerCase();
        final categoryName = categoriesMap[data['categoryId']] ?? 'Unknown';
        
        // Check if product contains non-pharmacy keywords
        bool isNonPharmacy = nonPharmacyKeywords.any((keyword) => 
          productTitle.contains(keyword.toLowerCase())
        );
        
        if (isNonPharmacy) {
          mismatchedProducts.add({
            'id': doc.id,
            'title': data['title'],
            'categoryId': data['categoryId'],
            'categoryName': categoryName,
            'reason': 'Non-pharmacy product (Food/Household)',
            'ref': doc.reference,
          });
          TLoggerHelper.warning('⚠️ MISMATCH: ${data['title']} in $categoryName (Non-pharmacy item)');
        }
      }
      
      TLoggerHelper.info('✅ AUDIT COMPLETE!');
      TLoggerHelper.info('📊 Total Checked: $totalChecked');
      TLoggerHelper.info('⚠️ Mismatched: ${mismatchedProducts.length}');
      
      setState(() {
        statusMessage = '✅ Audit Complete!';
        isProcessing = false;
      });
      
      if (mounted) {
        _showResultDialog();
      }
      
    } catch (e) {
      TLoggerHelper.error('Error during audit: $e');
      setState(() {
        statusMessage = '❌ Error: $e';
        isProcessing = false;
      });
    }
  }
  
  Future<void> deleteMismatchedProducts() async {
    if (mismatchedProducts.isEmpty) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Deletion'),
        content: Text(
          'Delete ${mismatchedProducts.length} mismatched products?\n\n'
          'This action cannot be undone!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      isProcessing = true;
      statusMessage = 'Deleting mismatched products...';
    });
    
    try {
      int deleted = 0;
      for (var product in mismatchedProducts) {
        await product['ref'].delete();
        deleted++;
        TLoggerHelper.info('🗑️ Deleted: ${product['title']}');
        
        if (deleted % 10 == 0) {
          setState(() => statusMessage = 'Deleted $deleted/${mismatchedProducts.length}...');
        }
      }
      
      TLoggerHelper.info('✅ DELETION COMPLETE! Deleted: $deleted products');
      
      setState(() {
        statusMessage = '✅ Deleted $deleted products!';
        isProcessing = false;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success'),
            content: Text('Successfully deleted $deleted mismatched products!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Re-audit
                  mismatchedProducts.clear();
                  auditCategories();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      TLoggerHelper.error('Error deleting products: $e');
      setState(() {
        statusMessage = '❌ Error: $e';
        isProcessing = false;
      });
    }
  }
  
  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Category Audit Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Products Checked: $totalChecked'),
              const SizedBox(height: 8),
              Text('Mismatched Products: ${mismatchedProducts.length}',
                style: TextStyle(
                  color: mismatchedProducts.isEmpty ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold
                )),
              const Divider(height: 24),
              if (mismatchedProducts.isEmpty) ...[
                const Text('✅ All products are in correct categories!',
                  style: TextStyle(color: Colors.green)),
              ] else ...[
                const Text('⚠️ Mismatched Products (first 20):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...mismatchedProducts.take(20).map((product) =>
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${product['title']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('  Category: ${product['categoryName']}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        Text('  Reason: ${product['reason']}',
                          style: const TextStyle(fontSize: 10, color: Colors.red)),
                      ],
                    ),
                  )
                ),
                if (mismatchedProducts.length > 20)
                  Text('... and ${mismatchedProducts.length - 20} more'),
              ],
            ],
          ),
        ),
        actions: [
          if (mismatchedProducts.isNotEmpty)
            ElevatedButton(
              onPressed: deleteMismatchedProducts,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete All Mismatched'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Product Categories'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.search,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Category Audit Tool',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: isProcessing ? Colors.orange : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isProcessing && mismatchedProducts.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Text('⚠️ Found: ${mismatchedProducts.length} mismatched products'),
                    const SizedBox(height: 8),
                    const Text('Items in wrong categories!', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isProcessing ? null : auditCategories,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
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
                      'START AUDIT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will:\n'
              '• Check all products in Firebase\n'
              '• Find items in wrong categories\n'
              '• Identify food/household items in pharmacy categories\n'
              '• Allow you to delete mismatched items',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
