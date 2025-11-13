import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../data/repository/user_repository/user_repository.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/constants/image_strings.dart';

class AccountPrivacyController extends GetxController {
  static AccountPrivacyController get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  final isGoogleConnected = false.obs;
  final isFacebookConnected = false.obs;
  final connectedEmail = ''.obs;
  final isLoading = false.obs;
  
  // Text controllers for password change
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final hideCurrentPassword = true.obs;
  final hideNewPassword = true.obs;
  final hideConfirmPassword = true.obs;
  
  GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    checkConnectedAccounts();
  }

  /// Check which accounts are connected
  void checkConnectedAccounts() {
    final user = _auth.currentUser;
    if (user != null) {
      final providerData = user.providerData;
      
      // Check Google connection
      final googleProvider = providerData.firstWhereOrNull(
        (info) => info.providerId == 'google.com'
      );
      if (googleProvider != null) {
        isGoogleConnected.value = true;
        connectedEmail.value = googleProvider.email ?? '';
      }
      
      // Check Facebook connection
      final facebookProvider = providerData.firstWhereOrNull(
        (info) => info.providerId == 'facebook.com'
      );
      isFacebookConnected.value = facebookProvider != null;
    }
  }

  /// Toggle Google account connection
  Future<void> toggleGoogleConnection(bool value) async {
    try {
      if (value) {
        // Connect Google account
        await connectGoogleAccount();
      } else {
        // Disconnect Google account
        await disconnectGoogleAccount();
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  /// Connect Google account
  Future<void> connectGoogleAccount() async {
    try {
      isLoading.value = true;
      
      // Sign in with Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return; // User cancelled
      }
      
      // Get Google credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Link Google account to current user
      await _auth.currentUser?.linkWithCredential(credential);
      
      // Update state
      isGoogleConnected.value = true;
      connectedEmail.value = googleUser.email;
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Google account connected successfully!',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        TLoaders.errorSnackBar(
          title: 'Already Linked',
          message: 'Google account is already linked to this user.',
        );
        isGoogleConnected.value = true;
      } else if (e.code == 'credential-already-in-use') {
        TLoaders.errorSnackBar(
          title: 'Account in Use',
          message: 'This Google account is already used by another user.',
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: e.message ?? 'Failed to connect Google account',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Something went wrong: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Disconnect Google account
  Future<void> disconnectGoogleAccount() async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Check if user has multiple sign-in methods
      final providerData = user.providerData;
      if (providerData.length <= 1) {
        TLoaders.warningSnackBar(
          title: 'Cannot Disconnect',
          message: 'You must have at least one sign-in method.',
        );
        isLoading.value = false;
        return;
      }
      
      // Unlink Google provider
      await user.unlink('google.com');
      
      // Sign out from Google
      await GoogleSignIn().signOut();
      
      // Update state
      isGoogleConnected.value = false;
      connectedEmail.value = '';
      
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Google account disconnected successfully!',
      );
    } on FirebaseAuthException catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: e.message ?? 'Failed to disconnect Google account',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Something went wrong: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password
  Future<void> changePasswordFunc() async {
    try {
      // Validate form
      if (!changePasswordFormKey.currentState!.validate()) {
        return;
      }

      // Show loader
      TFullScreenLoader.openLoadingDialog('Changing password...', TImages.docerAnimation);

      // Check if new passwords match
      if (newPassword.text.trim() != confirmPassword.text.trim()) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'New passwords do not match',
        );
        return;
      }

      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found',
        );
        return;
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword.text.trim());

      // Stop loader
      TFullScreenLoader.stopLoading();

      // Clear controllers
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();

      // Show success message
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Password changed successfully!',
      );

      // Go back
      Get.back();
    } on FirebaseAuthException catch (e) {
      TFullScreenLoader.stopLoading();
      if (e.code == 'wrong-password') {
        TLoaders.errorSnackBar(
          title: 'Wrong Password',
          message: 'Current password is incorrect',
        );
      } else if (e.code == 'weak-password') {
        TLoaders.errorSnackBar(
          title: 'Weak Password',
          message: 'Password should be at least 6 characters',
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: e.message ?? 'Failed to change password',
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  /// Download user data
  Future<void> downloadMyData() async {
    try {
      isLoading.value = true;
      TLoaders.customToast(message: 'Preparing your data...');

      final userId = AuthenticationRepository.instance.getUserID;
      
      // Fetch user data
      final userData = await UserRepository.instance.fetchUserDetails();
      
      // Fetch user's orders
      final ordersSnapshot = await _firestore
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Fetch user's prescriptions
      final prescriptionsSnapshot = await _firestore
          .collection('Prescriptions')
          .where('userId', isEqualTo: userId)
          .get();
      
      // Fetch user's addresses
      final addressesSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .get();
      
      // Compile all data
      final Map<String, dynamic> allData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userData': userData.toJson(),
        'orders': ordersSnapshot.docs.map((doc) => doc.data()).toList(),
        'prescriptions': prescriptionsSnapshot.docs.map((doc) => doc.data()).toList(),
        'addresses': addressesSnapshot.docs.map((doc) => doc.data()).toList(),
      };
      
      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
      
      isLoading.value = false;
      
      // Show success dialog with data preview
      Get.defaultDialog(
        title: 'Data Ready',
        middleText: 'Your data has been compiled. You can copy or share it.',
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
        ),
      );
      
      TLoaders.successSnackBar(
        title: 'Data Exported',
        message: 'Your data has been prepared successfully!',
        duration: 5,
      );
    } catch (e) {
      isLoading.value = false;
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to download data: ${e.toString()}',
      );
    }
  }

  /// Delete account permanently
  Future<void> deleteAccount() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.defaultDialog<bool>(
        title: 'Delete Account',
        middleText: 'Are you sure you want to permanently delete your account? This action cannot be undone.',
        textConfirm: 'Delete',
        textCancel: 'Cancel',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (confirmed != true) return;

      // Show loader
      TFullScreenLoader.openLoadingDialog('Deleting account...', TImages.docerAnimation);

      final userId = AuthenticationRepository.instance.getUserID;
      final user = _auth.currentUser;
      
      if (user == null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'User not found',
        );
        return;
      }

      // Delete user data from Firestore
      await _firestore.collection('Users').doc(userId).delete();
      
      // Delete user's addresses
      final addressesSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .get();
      
      for (var doc in addressesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Mark orders as deleted (don't actually delete for record keeping)
      final ordersSnapshot = await _firestore
          .collection('Orders')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in ordersSnapshot.docs) {
        await doc.reference.update({'userDeleted': true});
      }
      
      // Delete authentication account
      await user.delete();
      
      // Sign out
      await AuthenticationRepository.instance.logout();
      
      TFullScreenLoader.stopLoading();
      
      TLoaders.successSnackBar(
        title: 'Account Deleted',
        message: 'Your account has been permanently deleted.',
        duration: 5,
      );
    } on FirebaseAuthException catch (e) {
      TFullScreenLoader.stopLoading();
      if (e.code == 'requires-recent-login') {
        TLoaders.errorSnackBar(
          title: 'Re-authentication Required',
          message: 'Please log out and log in again before deleting your account.',
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: e.message ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
