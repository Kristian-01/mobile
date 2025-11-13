// Auto-Match ALL Medicines with MedsGo Prices
// Run: flutter run lib/utils/auto_match_medsgo_prices.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../utils/logging/logger.dart';
import 'medsgo_price_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AutoMatchPricesApp());
}

class AutoMatchPricesApp extends StatelessWidget {
  const AutoMatchPricesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AutoMatchScreen(),
    );
  }
}

class AutoMatchScreen extends StatefulWidget {
  const AutoMatchScreen({super.key});

  @override
  State<AutoMatchScreen> createState() => _AutoMatchScreenState();
}

class _AutoMatchScreenState extends State<AutoMatchScreen> {
  bool isProcessing = false;
  String statusMessage = 'Ready to auto-match MedsGo prices';
  int totalMedicines = 0;
  int matchedCount = 0;
  int unmatchedCount = 0;
  int updatedCount = 0;
  List<String> unmatchedMedicines = [];

  Future<void> autoMatchPrices() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Fetching all medicines...';
      matchedCount = 0;
      unmatchedCount = 0;
      updatedCount = 0;
      unmatchedMedicines.clear();
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Get all products
      final productsSnapshot = await db.collection('Products').get();
      totalMedicines = productsSnapshot.docs.length;
      
      TLoggerHelper.info('📦 Total medicines to process: $totalMedicines');
      setState(() => statusMessage = 'Matching with MedsGo database...');
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final productTitle = data['title'] as String? ?? '';
        final categoryId = (data['categoryId'] as String? ?? '').toLowerCase();
        
        // Try to find price in MedsGo database
        double? medsGoPrice = MedsGoPriceDatabase.findPrice(productTitle);
        
        double finalPrice;
        bool isMatched = false;
        
        if (medsGoPrice != null) {
          // Found exact/fuzzy match in MedsGo database
          finalPrice = medsGoPrice;
          isMatched = true;
          matchedCount++;
          TLoggerHelper.info('✅ MATCHED: $productTitle → ₱$finalPrice');
        } else {
          // No match - use smart defaults based on product type
          unmatchedCount++;
          unmatchedMedicines.add(productTitle);
          finalPrice = _getSmartDefaultPrice(productTitle, categoryId);
          TLoggerHelper.warning('⚠️ NO MATCH: $productTitle → Default ₱$finalPrice');
        }
        
        // Update Firebase
        await doc.reference.update({'price': finalPrice});
        updatedCount++;
        
        if (updatedCount % 25 == 0) {
          setState(() {
            statusMessage = 'Processed $updatedCount/$totalMedicines medicines...\n'
                'Matched: $matchedCount | Unmatched: $unmatchedCount';
          });
        }
      }
      
      TLoggerHelper.info('✅ AUTO-MATCH COMPLETE!');
      TLoggerHelper.info('📊 Total: $totalMedicines | Matched: $matchedCount | Unmatched: $unmatchedCount');
      
      setState(() {
        statusMessage = '✅ Complete!';
        isProcessing = false;
      });
      
      if (mounted) {
        _showResultDialog();
      }
      
    } catch (e) {
      TLoggerHelper.error('Error during auto-match: $e');
      setState(() {
        statusMessage = '❌ Error: $e';
        isProcessing = false;
      });
    }
  }
  
  double _getSmartDefaultPrice(String productTitle, String categoryId) {
    final titleLower = productTitle.toLowerCase();
    
    // Tablets/Capsules
    if (titleLower.contains('tablet') || titleLower.contains('capsule') || 
        titleLower.contains('cap ') || titleLower.contains('tab ')) {
      if (categoryId.contains('medicine')) return 5.00;
      if (categoryId.contains('baby') || categoryId.contains('multivitamin')) return 8.00;
      if (categoryId.contains('personal_care')) return 6.00;
      return 5.00;
    }
    
    // Syrups/Drops/Liquids
    if (titleLower.contains('syrup') || titleLower.contains('drops') || 
        titleLower.contains('suspension')) {
      if (titleLower.contains('60ml') || titleLower.contains('60 ml')) return 85.00;
      if (titleLower.contains('120ml') || titleLower.contains('120 ml')) return 150.00;
      if (titleLower.contains('30ml') || titleLower.contains('30 ml')) return 70.00;
      if (titleLower.contains('15ml') || titleLower.contains('15 ml')) return 50.00;
      return 100.00;
    }
    
    // Medical Supplies
    if (categoryId.contains('medical_supplies')) {
      if (titleLower.contains('alcohol')) return 45.00;
      if (titleLower.contains('gauze') || titleLower.contains('bandage')) return 25.00;
      if (titleLower.contains('cotton')) return 30.00;
      if (titleLower.contains('mask')) return 2.00;
      return 35.00;
    }
    
    // Feminine Care
    if (categoryId.contains('feminine') || categoryId.contains('female')) {
      if (titleLower.contains('napkin') || titleLower.contains('pad')) return 8.00;
      if (titleLower.contains('pantyliner')) return 5.00;
      return 40.00;
    }
    
    // Personal Care
    if (categoryId.contains('personal')) {
      if (titleLower.contains('soap')) return 15.00;
      if (titleLower.contains('shampoo')) return 8.00;
      if (titleLower.contains('toothpaste')) return 25.00;
      return 20.00;
    }
    
    // Baby Products
    if (categoryId.contains('baby')) {
      if (titleLower.contains('diaper')) return 12.00;
      if (titleLower.contains('wipes')) return 50.00;
      if (titleLower.contains('milk') || titleLower.contains('formula')) return 200.00;
      return 50.00;
    }
    
    return 10.00; // Generic default
  }
  
  void _showResultDialog() {
    final matchPercent = ((matchedCount / totalMedicines) * 100).toStringAsFixed(1);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Auto-Match Complete!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Total Medicines: $totalMedicines'),
              const SizedBox(height: 8),
              Text('✅ Matched with MedsGo: $matchedCount ($matchPercent%)',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text('⚠️ Smart Defaults: $unmatchedCount',
                style: const TextStyle(color: Colors.orange)),
              const Divider(height: 24),
              const Text('All prices updated!', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('• $matchedCount medicines have exact MedsGo prices'),
              Text('• $unmatchedCount medicines use market-based defaults'),
              if (unmatchedCount > 0) ...[
                const SizedBox(height: 16),
                const Text('Unmatched Medicines (first 10):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...unmatchedMedicines.take(10).map((med) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text('• $med', style: const TextStyle(fontSize: 11)),
                  )
                ),
                if (unmatchedCount > 10)
                  Text('... and ${unmatchedCount - 10} more'),
              ],
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Match MedsGo Prices'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.auto_fix_high,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Auto-Match MedsGo Prices',
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
            if (!isProcessing && updatedCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text('✅ Updated: $updatedCount medicines'),
                    const SizedBox(height: 8),
                    Text('Matched: $matchedCount | Defaults: $unmatchedCount',
                      style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isProcessing ? null : autoMatchPrices,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
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
                      'START AUTO-MATCH',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will:\n'
              '✅ Match 100+ medicines with exact MedsGo prices\n'
              '✅ Apply smart defaults for unmatched items\n'
              '✅ Update ALL 523 medicines automatically\n'
              '✅ Generate detailed report',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
