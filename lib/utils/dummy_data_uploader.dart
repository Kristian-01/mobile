// Run this ONCE to upload sample categories and products to Firestore
// Command: flutter run lib/utils/dummy_data_uploader.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'logger_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DataUploaderApp());
}

class DataUploaderApp extends StatelessWidget {
  const DataUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Upload Sample Data')),
        body: const DataUploader(),
      ),
    );
  }
}

class DataUploader extends StatelessWidget {
  const DataUploader({super.key});

  Future<void> uploadCategories() async {
    final db = FirebaseFirestore.instance;
    
    // Sample categories with all required fields and pharmacy images
    final categories = [
      {
        'id': '1',
        'name': 'Medicines',
        'image': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=150',
        'isFeatured': true,
        'parentId': null,
      },
      {
        'id': '2',
        'name': 'Vitamins & Supplements',
        'image': 'https://images.unsplash.com/photo-1556156653-e5a7676c6aac?w=150',
        'isFeatured': true,
        'parentId': null,
      },
      {
        'id': '3',
        'name': 'Topical & Oral Care',
        'image': 'https://images.unsplash.com/photo-1526045478516-99145907023c?w=150',
        'isFeatured': true,
        'parentId': null,
      },
      {
        'id': '4',
        'name': 'Cough & Cold',
        'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=150',
        'isFeatured': true,
        'parentId': null,
      },
    ];

    for (var category in categories) {
      await db.collection('Categories').doc(category['id'] as String).set(category);
      TLoggerHelper.info('✅ Uploaded: ${category['name']}');
    }
  }

  Future<void> uploadProducts() async {
    final db = FirebaseFirestore.instance;
    
    // Sample products with all required fields and pharmacy images
    final products = [
      {
        'id': '001',
        'title': 'Biogesic 500mg',
        'price': 5.50,
        'stock': 100,
        'thumbnail': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': '1', // Medicines
        'description': 'Paracetamol 500mg for fever and pain relief',
        'images': [
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300',
          'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=300',
        ],
      },
      {
        'id': '002',
        'title': 'Vitamin C 500mg',
        'price': 8.00,
        'stock': 50,
        'thumbnail': 'https://images.unsplash.com/photo-1556156653-e5a7676c6aac?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': '2', // Vitamins
        'description': 'Boost your immune system with Vitamin C',
        'images': [
          'https://images.unsplash.com/photo-1556156653-e5a7676c6aac?w=300',
        ],
      },
      {
        'id': '003',
        'title': 'Cough Syrup',
        'price': 120.00,
        'stock': 30,
        'thumbnail': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': '4', // Cough & Cold
        'description': 'Effective relief from cough and cold symptoms',
        'images': [
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300',
        ],
      },
      {
        'id': '004',
        'title': 'Toothpaste',
        'price': 45.00,
        'stock': 80,
        'thumbnail': 'https://images.unsplash.com/photo-1526045478516-99145907023c?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': '3', // Topical
        'description': 'Fresh breath and strong teeth',
        'images': [
          'https://images.unsplash.com/photo-1526045478516-99145907023c?w=300',
        ],
      },
      {
        'id': '005',
        'title': 'Multivitamins',
        'price': 250.00,
        'stock': 60,
        'thumbnail': 'https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': '2', // Vitamins
        'description': 'Complete daily multivitamin supplement',
        'images': [
          'https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=300',
        ],
      },
      {
        'id': '006',
        'title': 'Pain Relief Tablet',
        'price': 12.00,
        'stock': 150,
        'thumbnail': 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': '1', // Medicines
        'description': 'Fast-acting pain relief medication',
        'images': [
          'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=300',
        ],
      },
    ];

    for (var product in products) {
      await db.collection('Products').doc(product['id'] as String).set(product);
      TLoggerHelper.info('✅ Uploaded: ${product['title']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await uploadCategories();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Categories uploaded!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              }
            },
            child: const Text('Upload Categories'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await uploadProducts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Products uploaded!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              }
            },
            child: const Text('Upload Products'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await uploadCategories();
                await uploadProducts();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ All data uploaded!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              }
            },
            child: const Text('Upload ALL'),
          ),
        ],
      ),
    );
  }
}
