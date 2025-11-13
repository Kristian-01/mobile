// Update Category Icons in Firebase
// Run: flutter run lib/utils/update_category_icons.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'logger_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const UpdateCategoryIconsApp());
}

class UpdateCategoryIconsApp extends StatelessWidget {
  const UpdateCategoryIconsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Update Category Icons'),
          backgroundColor: Colors.blue,
        ),
        body: const UpdateCategoryIconsWidget(),
      ),
    );
  }
}

class UpdateCategoryIconsWidget extends StatefulWidget {
  const UpdateCategoryIconsWidget({super.key});

  @override
  State<UpdateCategoryIconsWidget> createState() => _UpdateCategoryIconsWidgetState();
}

class _UpdateCategoryIconsWidgetState extends State<UpdateCategoryIconsWidget> {
  bool isProcessing = false;
  String statusMessage = '';
  List<String> updatedCategories = [];

  Future<void> updateIcons() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Fetching categories...';
      updatedCategories.clear();
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Get all categories
      TLoggerHelper.info('📦 Fetching categories...');
      final categoriesSnapshot = await db.collection('Categories').get();
      
      setState(() => statusMessage = 'Updating ${categoriesSnapshot.docs.length} categories...');
      
      // Define icon mapping
      final iconMapping = {
        'baby_products': 'child_care',
        'baby products': 'child_care',
        'feminine_care': 'female',
        'feminine care': 'female',
        'female_care': 'female',
        'female care': 'female',
        'medicines': 'medication',
        'medicine': 'medication',
        'medical_supplies': 'medical_services',
        'medical supplies': 'medical_services',
        'personal_care': 'soap',
        'personal care': 'soap',
        'others': 'category',
      };
      
      int updated = 0;
      for (var doc in categoriesSnapshot.docs) {
        final data = doc.data();
        final categoryId = doc.id.toLowerCase();
        final categoryName = (data['name'] as String? ?? '').toLowerCase();
        
        // Find matching icon
        String? icon;
        for (var entry in iconMapping.entries) {
          if (categoryId.contains(entry.key) || categoryName.contains(entry.key)) {
            icon = entry.value;
            break;
          }
        }
        
        // Update category with icon
        if (icon != null) {
          await doc.reference.update({'icon': icon});
          TLoggerHelper.info('✅ Updated ${data['name']} → $icon');
          updatedCategories.add('${data['name']} → $icon');
          updated++;
        } else {
          TLoggerHelper.warning('⚠️ No icon mapping for: ${data['name']}');
        }
      }
      
      setState(() {
        statusMessage = '✅ SUCCESS! Updated $updated categories.';
        isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Updated $updated categories with icons!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
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
            const Icon(Icons.palette, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Update Category Icons',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'This will add icon field to all categories:\n\n'
              '👶 Baby Products → child_care\n'
              '👩 Feminine Care → female\n'
              '💊 Medicines → medication\n'
              '🏥 Medical Supplies → medical_services\n'
              '🧼 Personal Care → soap\n'
              '📦 Others → category',
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
            if (updatedCategories.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Updated Categories:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...updatedCategories.map((cat) => Text(cat, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (isProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: updateIcons,
                icon: const Icon(Icons.update),
                label: const Text('UPDATE ICONS NOW'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
