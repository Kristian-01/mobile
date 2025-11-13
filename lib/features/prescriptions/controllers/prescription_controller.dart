import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../data/repository/user_repository/user_repository.dart';
import '../models/prescription_model.dart';
import '../repositories/prescription_repository.dart';

class PrescriptionController extends GetxController {
  static PrescriptionController get instance => Get.find();

  final RxBool isLoading = false.obs;
  final RxBool isPicking = false.obs;
  final RxList<PrescriptionModel> userPrescriptions = <PrescriptionModel>[].obs;
  final prescriptionRepository = Get.put(PrescriptionRepository());
  final userRepository = Get.put(UserRepository());
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchUserPrescriptions();
  }

  /// Fetch all prescriptions for current user
  Future<void> fetchUserPrescriptions() async {
    try {
      isLoading.value = true;
      final prescriptions = await prescriptionRepository.getUserPrescriptions();
      userPrescriptions.assignAll(prescriptions);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload prescription from camera
  Future<void> uploadFromCamera(String patientName, String email, {String? notes}) async {
    // Prevent multiple picker instances
    if (isPicking.value) {
      Get.snackbar('Please wait', 'Image picker is already open',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isPicking.value = true;
      
      // Pick image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _uploadPrescription(image, patientName, email, notes: notes);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', 'Failed to capture image: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isPicking.value = false;
    }
  }

  /// Upload prescription from gallery
  Future<void> uploadFromGallery(String patientName, String email, {String? notes}) async {
    // Prevent multiple picker instances
    if (isPicking.value) {
      Get.snackbar('Please wait', 'Image picker is already open',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isPicking.value = true;
      
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _uploadPrescription(image, patientName, email, notes: notes);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', 'Failed to select image: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isPicking.value = false;
    }
  }

  /// Private method to upload prescription
  Future<void> _uploadPrescription(
    XFile image,
    String patientName,
    String email, {
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      // Get current user data
      final user = await userRepository.fetchUserDetails();

      // Upload image to Cloudinary
      print('📤 Starting image upload...');
      final imageUrl = await prescriptionRepository.uploadPrescriptionImage(image);
      
      print('📥 Received imageUrl: ${imageUrl.substring(0, imageUrl.length > 100 ? 100 : imageUrl.length)}...');
      print('📊 ImageUrl length: ${imageUrl.length} chars');
      
      if (imageUrl.isEmpty) {
        throw Exception('Failed to upload prescription image. Please try again.');
      }

      // Get file name from path
      final fileName = image.path.split('/').last;

      // Create prescription model
      final prescription = PrescriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthenticationRepository.instance.getUserID,
        userName: user.fullName,
        userEmail: user.email,
        userPhone: user.phoneNumber,
        imageUrl: imageUrl,
        fileName: fileName,
        patientName: patientName,
        email: email, // Use the email parameter
        notes: notes,
        status: 'pending',
        submittedAt: DateTime.now(),
        source: 'mobile', // Track upload source for notifications
      );

      print('💾 Saving to Firestore...');
      print('   - ID: ${prescription.id}');
      print('   - ImageURL: ${imageUrl.substring(0, 50)}...');
      print('   - Source: ${prescription.source}');
      
      // Save to Firestore
      await prescriptionRepository.savePrescription(prescription);
      
      print('✅ Saved to Firestore successfully!');

      // Refresh list
      await fetchUserPrescriptions();

      await Get.dialog(
        AlertDialog(
          title: const Text('Upload Successful'),
          content: const Text('Please wait for verification. We will notify you once it is available.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } on Exception catch (e) {
      Get.snackbar('Upload Failed', 
          'Failed to upload prescription: ${e.toString()}. Please try again.',
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete prescription
  Future<void> deletePrescription(String prescriptionId) async {
    try {
      isLoading.value = true;
      await prescriptionRepository.deletePrescription(prescriptionId);
      await fetchUserPrescriptions();
      Get.snackbar('Success', 'Prescription deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Get status color
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
      default:
        return 'orange';
    }
  }

  /// Get status text
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending Review';
    }
  }
}
