import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Email OTP Service for verification
/// Stores OTP in Firestore and verifies against it
class EmailOTPService {
  static final EmailOTPService _instance = EmailOTPService._internal();
  factory EmailOTPService() => _instance;
  EmailOTPService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate a 6-digit OTP
  String _generateOTP() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }

  /// Send OTP to user's email via Gmail SMTP
  Future<String> sendOTPToEmail(String email) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user found';

      // Generate OTP
      final otp = _generateOTP();

      // Store OTP in Firestore with expiration (5 minutes)
      await _firestore.collection('EmailVerifications').doc(user.uid).set({
        'email': email,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
        'verified': false,
      });

      debugPrint('✅ OTP Generated and stored: $otp for $email');

      // Send actual email via Gmail SMTP
      await _sendEmailViaSMTP(email, otp);
      
      return otp;
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      throw 'Failed to send OTP: $e';
    }
  }

  /// Send email using Gmail SMTP (Android/iOS) or Testing Mode (Web)
  Future<void> _sendEmailViaSMTP(String recipientEmail, String otp) async {
    // Web Platform: Display OTP for testing (Cloud Functions requires paid plan)
    if (kIsWeb) {
      debugPrint('🌐 Web Platform: Testing Mode');
      debugPrint('📧 Email: $recipientEmail');
      debugPrint('🔑 OTP CODE: $otp');
      debugPrint('⚠️ Note: Check browser console for OTP (email not sent on web)');
      // OTP is stored in Firestore and can be verified
      return;
    }

    try {
      // ⚠️ IMPORTANT: Replace with your Gmail credentials
      // For security, use App Password, not your actual Gmail password
      // Enable 2-Step Verification in Gmail, then generate App Password at:
      // https://myaccount.google.com/apppasswords
      
      final String username = 'avenido.kristian0@gmail.com'; // Replace with your Gmail
      final String password = 'fbkq bfnk fvhg xlqg';     // Replace with App Password
      
      final smtpServer = gmail(username, password);
      
      // Create email message
      final message = Message()
        ..from = Address(username, 'Nine27 Pharmacy')
        ..recipients.add(recipientEmail)
        ..subject = 'Your OTP Verification Code'
        ..html = '''
          <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #5B7FFF;">Email Verification</h2>
            <p>Hello,</p>
            <p>Your OTP verification code is:</p>
            <div style="background-color: #f0f0f0; padding: 20px; text-align: center; border-radius: 10px; margin: 20px 0;">
              <h1 style="color: #5B7FFF; letter-spacing: 10px; font-size: 36px; margin: 0;">$otp</h1>
            </div>
            <p>This code will expire in <strong>5 minutes</strong>.</p>
            <p>If you didn't request this code, please ignore this email.</p>
            <hr style="margin-top: 30px; border: none; border-top: 1px solid #ddd;">
            <p style="color: #888; font-size: 12px;">Nine27 Pharmacy - Your trusted health partner</p>
          </div>
        ''';

      // Send email
      final sendReport = await send(message, smtpServer);
      debugPrint('✅ Email sent successfully: \${sendReport.toString()}');
    } on MailerException catch (e) {
      debugPrint('❌ Email sending failed: \${e.message}');
      for (var p in e.problems) {
        debugPrint('Problem: \${p.code}: \${p.msg}');
      }
      // Don't throw error - continue even if email fails
      // OTP is still stored in Firestore
    } catch (e) {
      debugPrint('❌ Email error: $e');
      // Don't throw error - continue even if email fails
    }
  }

  /// Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user found';

      // Get OTP document
      final doc = await _firestore.collection('EmailVerifications').doc(user.uid).get();

      if (!doc.exists) {
        throw 'No OTP found. Please request a new one.';
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = data['expiresAt'] as Timestamp;
      final verified = data['verified'] as bool;

      // Check if already verified
      if (verified) {
        throw 'OTP already used. Please request a new one.';
      }

      // Check if expired
      if (DateTime.now().isAfter(expiresAt.toDate())) {
        throw 'OTP expired. Please request a new one.';
      }

      // Verify OTP
      if (storedOTP != otp) {
        throw 'Invalid OTP. Please try again.';
      }

      // Mark as verified
      await _firestore.collection('EmailVerifications').doc(user.uid).update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Manually verify email in Firebase Auth
      // Note: This is a workaround since we can't programmatically verify email
      // The user will be considered verified after OTP check
      debugPrint('✅ OTP Verified successfully');

      return true;
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      throw e.toString();
    }
  }

  /// Resend OTP
  Future<String> resendOTP(String email) async {
    return await sendOTPToEmail(email);
  }

  /// Check if OTP is still valid
  Future<bool> isOTPValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('EmailVerifications').doc(user.uid).get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final expiresAt = data['expiresAt'] as Timestamp;
      final verified = data['verified'] as bool;

      return !verified && DateTime.now().isBefore(expiresAt.toDate());
    } catch (e) {
      return false;
    }
  }

  /// Get OTP for testing (only in debug mode)
  Future<String?> getOTPForTesting() async {
    if (!kDebugMode) return null;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('EmailVerifications').doc(user.uid).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return data['otp'] as String;
    } catch (e) {
      return null;
    }
  }
}
