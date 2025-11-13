import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/success_screen/success_screen.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../data/repository/user_repository/user_repository.dart';
import '../../../data/services/email_otp/email_otp_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  final otpService = EmailOTPService();
  final isLoading = false.obs;
  final canResend = false.obs;
  final resendCooldown = 60.obs;
  Timer? _cooldownTimer;
  
  // OTP Input Controllers
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();
  final otp5 = TextEditingController();
  final otp6 = TextEditingController();

  @override
  void onInit() {
    /// Send OTP when screen appears
    sendOTPVerification();
    startResendCooldown();
    super.onInit();
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    otp4.dispose();
    otp5.dispose();
    otp6.dispose();
    super.onClose();
  }

  /// Send OTP to Email
  Future<void> sendOTPVerification() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user found';

      await otpService.sendOTPToEmail(user.email ?? '');
      
      // Show success message
      if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
      TLoaders.successSnackBar(
        title: '✅ OTP Sent!',
        message: 'Please check your email for the verification code.',
        duration: 5,
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Start cooldown for resend button
  void startResendCooldown() {
    canResend.value = false;
    resendCooldown.value = 60;
    
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value > 0) {
        resendCooldown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// Resend OTP
  Future<void> resendOTP() async {
    if (!canResend.value) return;
    
    await sendOTPVerification();
    startResendCooldown();
    
    // Clear OTP fields
    otp1.clear();
    otp2.clear();
    otp3.clear();
    otp4.clear();
    otp5.clear();
    otp6.clear();
  }

  /// Verify OTP
  Future<void> verifyOTP() async {
    try {
      // Get complete OTP
      final otp = otp1.text + otp2.text + otp3.text + otp4.text + otp5.text + otp6.text;
      
      if (otp.length != 6) {
        TLoaders.errorSnackBar(title: 'Incomplete', message: 'Please enter all 6 digits');
        return;
      }

      TFullScreenLoader.openLoadingDialog('Verifying OTP...', TImages.docerAnimation);

      // Verify OTP
      final verified = await otpService.verifyOTP(otp);

      if (verified) {
        // Update user's email verified status in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await UserRepository.instance.updateSingleField({
            'isEmailVerified': true,
            'emailVerifiedAt': FieldValue.serverTimestamp(),
          });
        }

        TFullScreenLoader.stopLoading();

        // Delete this controller to prevent memory leaks
        Get.delete<VerifyEmailController>();

        // Show success screen
        Get.off(
          () => SuccessScreen(
            image: TImages.successfullyRegisterAnimation,
            title: TTexts.yourAccountCreatedTitle,
            subTitle: TTexts.yourAccountCreatedSubTitle,
            onPressed: () {
              // Navigate to home - user is now verified
              AuthenticationRepository.instance.screenRedirect(FirebaseAuth.instance.currentUser);
            },
          ),
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Verification Failed', message: e.toString());
    }
  }
}
