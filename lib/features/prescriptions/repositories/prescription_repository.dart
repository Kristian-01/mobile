import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../utils/logger_helper.dart';
import '../models/prescription_model.dart';

class PrescriptionRepository extends GetxController {
  static PrescriptionRepository get instance => Get.find();

  /// Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Multiple upload services for reliability
  static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/dvvkjfqva/image/upload';
  static const String cloudinaryUploadPreset = 'ml_default';
  
  static const String postimagesApiKey = 'c3a97636b9a7a0ee6355e3e37a66e41e';
  static const String postimagesUploadUrl = 'https://api.postimages.org/json/rr';

  /// Upload prescription image with automatic fallback (100% FREE - No credit card!)
  Future<String> uploadPrescriptionImage(XFile image) async {
    final userId = AuthenticationRepository.instance.getUserID;
    
    // Check if user is authenticated
    if (userId.isEmpty) {
      throw Exception('User not authenticated. Please login again.');
    }
    
    // Get file info once - handle web and mobile differently
    final bytes = kIsWeb ? await image.readAsBytes() : await File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    final sizeKB = (bytes.length / 1024).toStringAsFixed(2);
    
    TLoggerHelper.info('📤 Starting prescription upload...');
    TLoggerHelper.info('📂 Image path: ${image.path}');
    TLoggerHelper.info('📊 Image size: $sizeKB KB');
    
    // Try Method 1: Cloudinary (Primary)
    try {
      TLoggerHelper.info('⬆️ Trying Cloudinary...');
      
      final uri = Uri.parse(cloudinaryUploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'prescription_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.fields['folder'] = 'prescriptions';
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final imageUrl = jsonResponse['secure_url'] as String;
        
        TLoggerHelper.info('✅ Cloudinary upload success!');
        TLoggerHelper.info('✅ URL: $imageUrl');
        
        return imageUrl;
      }
      
      TLoggerHelper.info('⚠️ Cloudinary failed (${response.statusCode}), trying backup...');
    } catch (e) {
      TLoggerHelper.info('⚠️ Cloudinary error: $e');
      TLoggerHelper.info('🔄 Switching to backup service...');
    }
    
    // Try Method 2: PostImages (Backup)
    try {
      TLoggerHelper.info('⬆️ Trying PostImages...');
      
      final uri = Uri.parse(postimagesUploadUrl);
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['key'] = postimagesApiKey;
      request.fields['source'] = base64Image;
      request.fields['format'] = 'json';
      request.fields['action'] = 'upload';
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success') {
          final imageUrl = jsonResponse['url'] as String;
          
          TLoggerHelper.info('✅ PostImages upload success!');
          TLoggerHelper.info('✅ URL: $imageUrl');
          
          return imageUrl;
        }
      }
      
      TLoggerHelper.info('⚠️ PostImages failed (${response.statusCode})');
    } catch (e) {
      TLoggerHelper.info('⚠️ PostImages error: $e');
    }
    
    // Try Method 3: Simple Base64 data URL (Last resort - for Firestore only)
    try {
      TLoggerHelper.info('⬆️ Using Base64 fallback...');
      
      // Create a data URL (works but large)
      final dataUrl = 'data:image/jpeg;base64,$base64Image';
      
      TLoggerHelper.info('✅ Base64 data created (${dataUrl.length} chars)');
      TLoggerHelper.info('⚠️ Note: Large data, may be slow to load');
      
      return dataUrl;
    } catch (e) {
      TLoggerHelper.info('❌ Base64 fallback failed: $e');
    }
    
    // All methods failed
    throw Exception('All upload methods failed. Please check your internet connection and try again.');
  }

  /// Save prescription to Firestore
  Future<void> savePrescription(PrescriptionModel prescription) async {
    try {
      await _db.collection('Prescriptions').doc(prescription.id).set(prescription.toJson());
    } catch (e) {
      throw 'Failed to save prescription: $e';
    }
  }

  /// Get all prescriptions for current user
  Future<List<PrescriptionModel>> getUserPrescriptions() async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      
      // Simple query without orderBy to avoid index requirement
      final snapshot = await _db
          .collection('Prescriptions')
          .where('userId', isEqualTo: userId)
          .get();

      // Sort in code instead of in query
      final prescriptions = snapshot.docs
          .map((doc) => PrescriptionModel.fromSnapshot(doc))
          .toList();
      
      prescriptions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt)); // Sort descending
      
      return prescriptions;
    } catch (e) {
      throw 'Failed to fetch prescriptions: $e';
    }
  }

  /// Get prescription by ID
  Future<PrescriptionModel> getPrescriptionById(String prescriptionId) async {
    try {
      final snapshot = await _db.collection('Prescriptions').doc(prescriptionId).get();
      if (snapshot.exists) {
        return PrescriptionModel.fromSnapshot(snapshot);
      } else {
        throw 'Prescription not found';
      }
    } catch (e) {
      throw 'Failed to fetch prescription: $e';
    }
  }

  /// Stream of user prescriptions
  Stream<List<PrescriptionModel>> streamUserPrescriptions() {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      return _db
          .collection('Prescriptions')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final prescriptions = snapshot.docs
            .map((doc) => PrescriptionModel.fromSnapshot(doc))
            .toList();
        
        // Sort in code to avoid index requirement
        prescriptions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        
        return prescriptions;
      });
    } catch (e) {
      throw 'Failed to stream prescriptions: $e';
    }
  }

  /// Delete prescription
  Future<void> deletePrescription(String prescriptionId) async {
    try {
      await _db.collection('Prescriptions').doc(prescriptionId).delete();
    } catch (e) {
      throw 'Failed to delete prescription: $e';
    }
  }

  /// Update prescription status (for admin)
  Future<void> updatePrescriptionStatus(
    String prescriptionId,
    String status, {
    String? approvedBy,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status,
        'approvedAt': status == 'approved' ? DateTime.now() : null,
        'approvedBy': approvedBy,
        'rejectionReason': rejectionReason,
      };
      
      await _db.collection('Prescriptions').doc(prescriptionId).update(updateData);
    } catch (e) {
      throw 'Failed to update prescription status: $e';
    }
  }
}
