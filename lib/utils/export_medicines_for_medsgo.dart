// Export All Medicines to CSV for MedsGo Price Matching
// Run: flutter run lib/utils/export_medicines_for_medsgo.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../firebase_options.dart';
import '../utils/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExportMedicinesApp());
}

class ExportMedicinesApp extends StatelessWidget {
  const ExportMedicinesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ExportMedicinesScreen(),
    );
  }
}

class ExportMedicinesScreen extends StatefulWidget {
  const ExportMedicinesScreen({super.key});

  @override
  State<ExportMedicinesScreen> createState() => _ExportMedicinesScreenState();
}

class _ExportMedicinesScreenState extends State<ExportMedicinesScreen> {
  bool isProcessing = false;
  String statusMessage = 'Ready to export medicines';
  int totalMedicines = 0;
  String exportPath = '';

  Future<void> exportMedicinesToCSV() async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Fetching medicines from Firebase...';
    });

    try {
      final db = FirebaseFirestore.instance;
      
      // Get all products
      final productsSnapshot = await db.collection('Products').get();
      totalMedicines = productsSnapshot.docs.length;
      
      TLoggerHelper.info('📦 Total medicines: $totalMedicines');
      setState(() => statusMessage = 'Creating CSV file...');
      
      // Create CSV content
      StringBuffer csv = StringBuffer();
      csv.writeln('Product Name,Category,Current Price,Brand,Generic Name,Dosage,Form');
      
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final title = (data['title'] as String? ?? '').replaceAll(',', ';');
        final category = data['categoryId'] as String? ?? '';
        final price = data['price'] ?? 0.0;
        final brand = (data['brand'] as String? ?? '').replaceAll(',', ';');
        
        // Try to extract form (tablet, capsule, syrup, etc.) from title
        final titleLower = title.toLowerCase();
        String form = '';
        if (titleLower.contains('tablet')) form = 'Tablet';
        else if (titleLower.contains('capsule') || titleLower.contains('cap')) form = 'Capsule';
        else if (titleLower.contains('syrup')) form = 'Syrup';
        else if (titleLower.contains('drops')) form = 'Drops';
        else if (titleLower.contains('suspension')) form = 'Suspension';
        else if (titleLower.contains('lotion')) form = 'Lotion';
        else if (titleLower.contains('cream')) form = 'Cream';
        else if (titleLower.contains('ointment')) form = 'Ointment';
        
        // Try to extract dosage from title
        String dosage = '';
        final dosageMatch = RegExp(r'(\d+)\s*(mg|ml|g|mcg)').firstMatch(titleLower);
        if (dosageMatch != null) {
          dosage = dosageMatch.group(0) ?? '';
        }
        
        csv.writeln('$title,$category,$price,$brand,,$dosage,$form');
      }
      
      // Save CSV file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medicines_for_medsgo.csv');
      await file.writeAsString(csv.toString());
      exportPath = file.path;
      
      TLoggerHelper.info('✅ CSV exported to: $exportPath');
      
      setState(() {
        statusMessage = '✅ Export Complete!';
        isProcessing = false;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Export Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exported $totalMedicines medicines'),
                const SizedBox(height: 16),
                const Text('CSV saved to:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SelectableText(exportPath,
                  style: const TextStyle(fontSize: 12, color: Colors.blue)),
                const SizedBox(height: 16),
                const Text('Next Steps:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  '1. Check the CSV file\n'
                  '2. We will auto-match with MedsGo prices\n'
                  '3. Review unmatched items',
                  style: TextStyle(fontSize: 12),
                ),
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
      TLoggerHelper.error('Error exporting medicines: $e');
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
        title: const Text('Export Medicines'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.upload_file,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Export All Medicines',
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
            if (!isProcessing && totalMedicines > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text('✅ Exported: $totalMedicines medicines'),
                    const SizedBox(height: 8),
                    const Text('CSV file ready for processing!', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isProcessing ? null : exportMedicinesToCSV,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
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
                      'EXPORT TO CSV',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will:\n'
              '• Export all 523 medicines to CSV\n'
              '• Prepare for MedsGo price matching\n'
              '• Generate a list for review',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
