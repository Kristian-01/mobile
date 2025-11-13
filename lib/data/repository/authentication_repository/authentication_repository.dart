import 'package:cwt_starter_template/features/authentication/screens/on_boarding/on_boarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../features/authentication/screens/welcome/welcome_screen.dart';
import '../../../features/navigation_menu/navigation_menu.dart';
import '../../../personalization/controllers/notification_controller.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/popups/loaders.dart';
import '../user_repository/user_repository.dart';

/// -- README(Docs[6]) -- Bindings
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage(); // Use this to store data locally (e.g. OnBoarding)
  late final Rx<User?> _firebaseUser;
  final _auth = FirebaseAuth.instance;
  int? _resendToken;
  final phoneNoVerificationId = ''.obs;

  /// Getters
  User? get firebaseUser => _firebaseUser.value;

  String get getUserID => firebaseUser?.uid ?? "";

  String get getUserEmail => firebaseUser?.email ?? "";

  String get getDisplayName => firebaseUser?.displayName ?? "";


  /// Loads when app Launch from main.dart
  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    FlutterNativeSplash.remove();
    screenRedirect(_firebaseUser.value);
    // ever(_firebaseUser, _setInitialScreen);
  }

  /// Function to Show Relevant Screen
  screenRedirect(User? user) async {
    try {
      if (user != null) {
        debugPrint('🔄 Screen redirect started for user: ${user.email}');
        
        // Check if user signed in with Google or other social providers
        final providerData = user.providerData;
        final isGoogleSignIn = providerData.any((info) => info.providerId == 'google.com');
        final isFacebookSignIn = providerData.any((info) => info.providerId == 'facebook.com');
        final isSocialSignIn = isGoogleSignIn || isFacebookSignIn;

        debugPrint('🔐 Social sign-in: $isSocialSignIn');

        // For social sign-in users, automatically verify email in Firestore
        if (isSocialSignIn) {
          try {
            await UserRepository.instance.updateSingleField({
              'isEmailVerified': true,
            }).timeout(const Duration(seconds: 10));
            debugPrint('✅ Email verified for social sign-in');
          } catch (e) {
            debugPrint('⚠️ Error updating email verification: $e');
          }
        }

        // Fetch User Record - force fetch latest to get updated isEmailVerified status
        debugPrint('📥 Fetching user record...');
        final userController = Get.put(UserController());
        await userController.fetchUserRecord(fetchLatestRecord: true).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏱️ Fetch user record timeout - using empty user');
            return;
          },
        );
        debugPrint('✅ User record fetched');

        // Use this to check auth Role for admin
        final idTokenResult = await _auth.currentUser!.getIdTokenResult();

        // Check if email verified - use Firestore field instead of Firebase Auth
        final userRecord = UserController.instance.user.value;
        final isEmailVerified = userRecord.isEmailVerified ?? false;

        debugPrint('📧 Email verified: $isEmailVerified');

        // If email verified let the user go to Home Screen else to the Email Verification Screen
        if (isEmailVerified || idTokenResult.claims?['admin'] == true) {
          // Initialize User Specific Storage
          await TLocalStorage.init(user.uid);
          
          // Start notification listener after successful login
          try {
            if (Get.isRegistered<NotificationController>()) {
              NotificationController.instance.startListening();
            } else {
              final notificationController = Get.put(NotificationController());
              notificationController.startListening();
            }
          } catch (e) {
            // Silently handle notification initialization errors
            debugPrint('Notification initialization error: $e');
          }
          
          debugPrint('🏠 Navigating to home...');
          Get.offAll(() => const NavigationMenu());
        } else {
          debugPrint('📨 Navigating to email verification...');
          Get.offAll(() => VerifyEmailScreen(email: getUserEmail));
        }
      } else {
        deviceStorage.writeIfNull('isFirstTime', true);
        final bool isFirstTime = deviceStorage.read('isFirstTime') as bool;

        if (isFirstTime) {
          // First launch: go to OnBoarding
          await Get.offAll(() => const OnBoardingScreen());
          // After showing onboarding, mark it done:
          deviceStorage.write('isFirstTime', false);
        } else {
          // Not first launch: go to Welcome or Login
          Get.offAll(() => const WelcomeScreen());
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in screenRedirect: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback to welcome screen on error
      Get.offAll(() => const WelcomeScreen());
    }
  }

  /* ---------------------------- Email & Password sign-in ---------------------------------*/

  /// [EmailAuthentication] - SignIn
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [ReAuthenticate] - ReAuthenticate User
  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [EmailVerification] - MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /* ---------------------------- Phone Authentication ---------------------------------*/

  /// [PhoneAuthentication] - Login with Phone Number
  Future<void> loginWithPhoneNo(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw TFirebaseAuthException(e.code).message;
        },
        codeSent: (String verificationId, int? resendToken) {
          phoneNoVerificationId.value = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          phoneNoVerificationId.value = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [PhoneAuthentication] - Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: phoneNoVerificationId.value,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /* ---------------------------- Federated identity & social sign-in ---------------------------------*/

  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign-In...');
      final startTime = DateTime.now();
      
      // Trigger the authentication flow
      debugPrint('🔵 Opening Google Sign-In dialog...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      debugPrint('✅ Google account selected: ${DateTime.now().difference(startTime).inSeconds}s');

      // Obtain the auth details from the request
      debugPrint('🔵 Getting authentication details...');
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      debugPrint('✅ Auth details obtained: ${DateTime.now().difference(startTime).inSeconds}s');

      // Create a new credential
      debugPrint('🔵 Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      // Once signed in, return the UserCredential
      debugPrint('🔵 Signing in to Firebase...');
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('✅ Sign-in complete! Total time: ${DateTime.now().difference(startTime).inSeconds}s');
      return result;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      debugPrint('Something went wrong: $e');
      return null;
    }
  }


  ///[FacebookAuthentication] - FACEBOOK
  // Future<UserCredential> signInWithFacebook() async {
  //   try {
  //     // Trigger the sign-in flow
  //     final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email']);
  //
  //     // Create a credential from the access token
  //     final AccessToken accessToken = loginResult.accessToken!;
  //     final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);
  //
  //     // Once signed in, return the UserCredential
  //     return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  //   } on FirebaseAuthException catch (e) {
  //     throw TFirebaseAuthException(e.code).message;
  //   } on FirebaseException catch (e) {
  //     throw TFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  /* ---------------------------- ./end Federated identity & social sign-in ---------------------------------*/

  /// [LogoutUser] - Valid for any authentication.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      // await FacebookAuth.instance.logOut();
      // await FirebaseAuth.instance.signOut();
      Get.offAll(() => const WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// DELETE USER - Remove user Auth and Firestore Account.
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
