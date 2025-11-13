// Nine27Pharmacy Complete Product Data Uploader
// Run: flutter run lib/utils/upload_pharmacy_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'logger_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PharmacyDataUploaderApp());
}

class PharmacyDataUploaderApp extends StatelessWidget {
  const PharmacyDataUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nine27Pharmacy Data Uploader'),
          backgroundColor: Colors.blue,
        ),
        body: const PharmacyDataUploader(),
      ),
    );
  }
}

class PharmacyDataUploader extends StatefulWidget {
  const PharmacyDataUploader({super.key});

  @override
  State<PharmacyDataUploader> createState() => _PharmacyDataUploaderState();
}

class _PharmacyDataUploaderState extends State<PharmacyDataUploader> {
  bool isUploading = false;
  String statusMessage = '';

  Future<void> uploadAllData() async {
    setState(() {
      isUploading = true;
      statusMessage = 'Starting upload...';
    });

    try {
      await uploadCategories();
      setState(() => statusMessage = 'Categories uploaded!');
      
      await Future.delayed(const Duration(seconds: 1));
      
      await uploadProducts();
      setState(() => statusMessage = 'All data uploaded successfully! ✅');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Upload complete!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => statusMessage = 'Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> uploadCategories() async {
    final db = FirebaseFirestore.instance;
    
    final categories = [
      // Main Categories
      {
        'id': 'pharmaceuticals',
        'name': 'Pharmaceuticals & Supplements',
        'image': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=200',
        'isFeatured': true,
        'parentId': null,
      },
      {
        'id': 'personal_care',
        'name': 'Personal Care & Hygiene',
        'image': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=200',
        'isFeatured': true,
        'parentId': null,
      },
      {
        'id': 'health_wellness',
        'name': 'Health & Wellness',
        'image': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=200',
        'isFeatured': true,
        'parentId': null,
      },
      
      // Subcategories - Pharmaceuticals
      {
        'id': 'multivitamins',
        'name': 'Multivitamins & Supplements',
        'image': 'https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=200',
        'isFeatured': false,
        'parentId': 'pharmaceuticals',
      },
      {
        'id': 'medicines',
        'name': 'Medicines',
        'image': 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=200',
        'isFeatured': false,
        'parentId': 'pharmaceuticals',
      },
      {
        'id': 'topical_oral',
        'name': 'Topical & Oral Treatments',
        'image': 'https://images.unsplash.com/photo-1526045478516-99145907023c?w=200',
        'isFeatured': false,
        'parentId': 'pharmaceuticals',
      },
      {
        'id': 'cough_cold',
        'name': 'Cough & Cold',
        'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200',
        'isFeatured': false,
        'parentId': 'pharmaceuticals',
      },
      
      // Subcategories - Personal Care
      {
        'id': 'baby_care',
        'name': 'Baby Care',
        'image': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200',
        'isFeatured': false,
        'parentId': 'personal_care',
      },
      {
        'id': 'skin_beauty',
        'name': 'Skin Care & Beauty',
        'image': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=200',
        'isFeatured': false,
        'parentId': 'personal_care',
      },
      {
        'id': 'oral_care',
        'name': 'Oral Care',
        'image': 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=200',
        'isFeatured': false,
        'parentId': 'personal_care',
      },
      {
        'id': 'hair_care',
        'name': 'Shampoos & Hair Care',
        'image': 'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=200',
        'isFeatured': false,
        'parentId': 'personal_care',
      },
      {
        'id': 'deodorants',
        'name': 'Deodorants & Fragrances',
        'image': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=200',
        'isFeatured': false,
        'parentId': 'personal_care',
      },
    ];

    for (var category in categories) {
      await db.collection('Categories').doc(category['id'] as String).set(category);
      TLoggerHelper.info('✅ Category: ${category['name']}');
    }
  }

  Future<void> uploadProducts() async {
    final db = FirebaseFirestore.instance;
    int productId = 1;
    
    // Multivitamins & Supplements
    final multivitamins = [
      {'name': 'Appetason 120ml Syrup', 'price': 150.00, 'stock': 50},
      {'name': 'MYREVIT Multivitamins Capsule', 'price': 8.50, 'stock': 100},
      {'name': 'Myra E Classic Whitening Lotion 200ml', 'price': 285.00, 'stock': 30},
      {'name': 'Memo Plus Gold', 'price': 12.00, 'stock': 80},
      {'name': 'MYREVIT Multivitamins Drops', 'price': 95.00, 'stock': 40},
      {'name': 'FORALIVIT Multivitamins + Iron Capsule', 'price': 10.00, 'stock': 70},
      {'name': 'EURIVIT Multivitamins + Mineral Syrup', 'price': 120.00, 'stock': 45},
    ];
    
    for (var product in multivitamins) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': 'multivitamins',
        'description': 'High-quality vitamin supplement for daily health',
        'images': ['https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Medicines
    final medicines = [
      {'name': 'AMBIMOX Amoxicillin 500mg Capsule', 'price': 12.00, 'stock': 150},
      {'name': 'AXMEL Amoxicillin 125mg Suspension', 'price': 85.00, 'stock': 60},
      {'name': 'CETIREX Cetirizine 6mg/5ml Syrup', 'price': 65.00, 'stock': 70},
      {'name': 'FLUGARD Paracetamol 500mg Tablet', 'price': 5.50, 'stock': 200},
      {'name': 'MOXYLOR Amoxicillin 250mg Suspension', 'price': 95.00, 'stock': 55},
      {'name': 'Azithromycin 500mg', 'price': 45.00, 'stock': 80},
      {'name': 'VENTOMAX Salbutamol 2mg Tablet', 'price': 8.00, 'stock': 90},
      {'name': 'MYREVIT C Ascorbic Acid 120ml Syrup', 'price': 110.00, 'stock': 50},
      {'name': 'MECID Mefenamic Acid 500mg Capsule', 'price': 10.00, 'stock': 120},
      {'name': 'PRENISAPH-10 Prednisone 10mg Tablet', 'price': 15.00, 'stock': 60},
    ];
    
    for (var product in medicines) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': 'medicines',
        'description': 'Prescription medicine - Consult your doctor',
        'images': ['https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Topical & Oral Treatments
    final topicals = [
      {'name': 'Betadine Solution 15ml', 'price': 45.00, 'stock': 80},
      {'name': 'Betnovate Cream 5g', 'price': 120.00, 'stock': 40},
      {'name': 'Silver Sulfadiazide Cream 30g', 'price': 85.00, 'stock': 35},
      {'name': 'MUPIBAN Mupirocin Ointment 5g Tube', 'price': 95.00, 'stock': 50},
      {'name': 'Mucolvan Retard 75mg Capsule', 'price': 18.00, 'stock': 70},
    ];
    
    for (var product in topicals) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1526045478516-99145907023c?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'topical_oral',
        'description': 'Topical treatment for skin care',
        'images': ['https://images.unsplash.com/photo-1526045478516-99145907023c?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Cough & Cold
    final coughCold = [
      {'name': 'Solmux Advance 60ml', 'price': 135.00, 'stock': 60},
      {'name': 'Solmux Capsule', 'price': 10.00, 'stock': 100},
      {'name': 'Solmux Forte 200mg Syrup', 'price': 155.00, 'stock': 45},
      {'name': 'Solmux Drops 100mg 60ml', 'price': 125.00, 'stock': 40},
      {'name': 'Tiki-Tiki Syrup 120ml', 'price': 95.00, 'stock': 55},
    ];
    
    for (var product in coughCold) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': 'cough_cold',
        'description': 'Effective relief from cough and cold',
        'images': ['https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Baby Care
    final babyCare = [
      {'name': "Johnson's Baby Oil 50ml", 'price': 85.00, 'stock': 60},
      {'name': "Johnson's Baby Powder Classic 25g", 'price': 45.00, 'stock': 80},
      {'name': 'Lactacyd Baby Body & Hair Wash 60ml', 'price': 95.00, 'stock': 50},
      {'name': 'Babyflo Pacifier', 'price': 65.00, 'stock': 40},
      {'name': 'Kleenfant Anti-Bacterial Wipes 21 sheets', 'price': 55.00, 'stock': 70},
      {'name': 'Kleenfant Baby Wipes 11 sheets', 'price': 35.00, 'stock': 90},
    ];
    
    for (var product in babyCare) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'baby_care',
        'description': 'Gentle care for your baby',
        'images': ['https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Skin Care & Beauty
    final skinCare = [
      {'name': 'KojieSan Classic Soap 135g', 'price': 95.00, 'stock': 70},
      {'name': 'Silka Orange Papaya Soap 65g', 'price': 35.00, 'stock': 100},
      {'name': 'Silka Green Soap 135g', 'price': 55.00, 'stock': 80},
      {'name': 'Silka Facial Cleanser Clear 150ml', 'price': 145.00, 'stock': 50},
      {'name': 'Ponds Activated Charcoal Facial Foam 50g', 'price': 110.00, 'stock': 60},
      {'name': 'Ponds Whitening Cream', 'price': 155.00, 'stock': 45},
    ];
    
    for (var product in skinCare) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'skin_beauty',
        'description': 'Premium skin care product',
        'images': ['https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Oral Care
    final oralCare = [
      {'name': 'Colgate Classic Toothbrush', 'price': 45.00, 'stock': 100},
      {'name': 'Colgate Max Cavity 74g', 'price': 75.00, 'stock': 80},
      {'name': 'Colgate Super Flexi Toothbrush', 'price': 55.00, 'stock': 90},
      {'name': 'Oral-B 3-in-1 Toothbrush', 'price': 65.00, 'stock': 70},
    ];
    
    for (var product in oralCare) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'oral_care',
        'description': 'Complete oral hygiene solution',
        'images': ['https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Hair Care
    final hairCare = [
      {'name': 'Creamsilk Keratin Damage Repair 75ml', 'price': 85.00, 'stock': 60},
      {'name': 'Sunsilk Shampoo Pink 15ml', 'price': 12.00, 'stock': 120},
      {'name': 'Head & Shoulders Shampoo Sachet', 'price': 8.00, 'stock': 150},
      {'name': 'Clear Men Shampoo Sachet', 'price': 8.00, 'stock': 140},
    ];
    
    for (var product in hairCare) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'hair_care',
        'description': 'Professional hair care',
        'images': ['https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Deodorants & Fragrances
    final deodorants = [
      {'name': 'Bench Body Spray Pure Passion 100ml', 'price': 125.00, 'stock': 50},
      {'name': 'Bench Colonia Bubble Gum 50ml', 'price': 65.00, 'stock': 60},
      {'name': 'Bench Colonia Cotton Candy 100ml', 'price': 95.00, 'stock': 55},
      {'name': 'AXE Roll-On Apollo 25ml', 'price': 110.00, 'stock': 45},
    ];
    
    for (var product in deodorants) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=300',
        'productType': 'ProductType.single',
        'isFeatured': false,
        'categoryId': 'deodorants',
        'description': 'Long-lasting freshness',
        'images': ['https://images.unsplash.com/photo-1541643600914-78b084683601?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
    }

    // Health & Wellness - Additional Products
    final wellness = [
      {'name': 'Biogesic 500mg Tab', 'price': 5.50, 'stock': 200, 'cat': 'medicines'},
      {'name': 'Nutroplex Syrup', 'price': 145.00, 'stock': 50, 'cat': 'multivitamins'},
      {'name': 'Cecon 500mg Chewable Tab (Ascorbic)', 'price': 8.00, 'stock': 100, 'cat': 'multivitamins'},
      {'name': 'Ceelin Drops 15ml', 'price': 185.00, 'stock': 40, 'cat': 'multivitamins'},
      {'name': 'Ceelin Plus Syrup 120ml', 'price': 205.00, 'stock': 35, 'cat': 'multivitamins'},
      {'name': 'Alaxan FR', 'price': 12.00, 'stock': 120, 'cat': 'medicines'},
      {'name': 'Ascof 600mg Syrup', 'price': 155.00, 'stock': 45, 'cat': 'cough_cold'},
      {'name': 'Tempra Forte 250mg Orange 120ml', 'price': 195.00, 'stock': 50, 'cat': 'medicines'},
      {'name': 'Biogesic Syrup 250mg 60ml', 'price': 95.00, 'stock': 60, 'cat': 'medicines'},
    ];
    
    for (var product in wellness) {
      await db.collection('Products').doc('P${productId.toString().padLeft(3, '0')}').set({
        'id': 'P${productId.toString().padLeft(3, '0')}',
        'title': product['name'],
        'price': product['price'],
        'stock': product['stock'],
        'thumbnail': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=300',
        'productType': 'ProductType.single',
        'isFeatured': true,
        'categoryId': product['cat'],
        'description': 'Quality health and wellness product',
        'images': ['https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=300'],
      });
      TLoggerHelper.info('✅ Product: ${product['name']}');
      productId++;
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
            const Icon(Icons.local_pharmacy, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Nine27Pharmacy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Complete Product Database Uploader',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
            if (isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: uploadAllData,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload All Products to Firebase'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'This will upload:\n• 3 Main Categories\n• 10 Subcategories\n• 60+ Real Products',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
