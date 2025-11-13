// Fix Categories - Delete all and upload correct 6 categories
// Run: flutter run lib/utils/fix_categories.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'logger_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FixCategoriesApp());
}

class FixCategoriesApp extends StatelessWidget {
  const FixCategoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fix Categories - 6 Only'),
          backgroundColor: Colors.red,
        ),
        body: const FixCategoriesWidget(),
      ),
    );
  }
}

class FixCategoriesWidget extends StatefulWidget {
  const FixCategoriesWidget({super.key});

  @override
  State<FixCategoriesWidget> createState() => _FixCategoriesWidgetState();
}

class _FixCategoriesWidgetState extends State<FixCategoriesWidget> {
  bool isProcessing = false;
  String statusMessage = '';

  Future<void> fixCategories() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Deleting all existing categories...';
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Step 1: Delete ALL existing categories
      TLoggerHelper.info('🗑️ Deleting all categories...');
      final existingCategories = await db.collection('Categories').get();
      for (var doc in existingCategories.docs) {
        await doc.reference.delete();
        TLoggerHelper.info('❌ Deleted: ${doc.id}');
      }
      
      setState(() => statusMessage = 'Creating 6 correct categories...');
      await Future.delayed(const Duration(seconds: 1));
      
      // Step 2: Upload ONLY 6 main categories
      final categories = [
        {
          'id': 'baby_products',
          'name': 'Baby Products',
          'image': '', // Will be set from Firebase Storage later
          'icon': 'child_care',
          'isFeatured': true,
          'parentId': null,
        },
        {
          'id': 'feminine_care',
          'name': 'Feminine Care',
          'image': '',
          'icon': 'female',
          'isFeatured': true,
          'parentId': null,
        },
        {
          'id': 'medicines',
          'name': 'Medicines',
          'image': '',
          'icon': 'medication',
          'isFeatured': true,
          'parentId': null,
        },
        {
          'id': 'medical_supplies',
          'name': 'Medical Supplies',
          'image': '',
          'icon': 'medical_services',
          'isFeatured': true,
          'parentId': null,
        },
        {
          'id': 'personal_care',
          'name': 'Personal Care',
          'image': '',
          'icon': 'soap',
          'isFeatured': true,
          'parentId': null,
        },
        {
          'id': 'others',
          'name': 'Others',
          'image': '',
          'icon': 'category',
          'isFeatured': true,
          'parentId': null,
        },
      ];

      for (var category in categories) {
        await db.collection('Categories').doc(category['id'] as String).set(category);
        TLoggerHelper.info('✅ Created: ${category['name']}');
      }
      
      setState(() {
        statusMessage = '✅ SUCCESS! Fixed to 6 categories only.';
        isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Categories fixed! You now have exactly 6 categories.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        statusMessage = '❌ Error: $e';
        isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Fix Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This will DELETE all categories and create exactly 6:\n\n'
              '1. Baby Products\n'
              '2. Feminine Care\n'
              '3. Medicines\n'
              '4. Medical Supplies\n'
              '5. Personal Care\n'
              '6. Others',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  statusMessage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            if (isProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: fixCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('FIX CATEGORIES NOW'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
