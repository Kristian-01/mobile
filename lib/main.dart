import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';
import 'data/repository/authentication_repository/authentication_repository.dart';
import 'data/services/analytics/analytics_service.dart';
import 'data/services/notifications/firestore_notification_listener.dart';
import 'firebase_options.dart';
import 'utils/logger_helper.dart';

/// ------ For Docs & Updates Check ------
/// ------------- README.md --------------

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// -- README(Update[]) -- GetX Local Storage
  await GetStorage.init();

  /// -- README(Docs[1]) -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- README(Docs[2]) -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((_) {
    // Configure Firestore for real-time updates with server priority
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    TLoggerHelper.info('🔥 Firestore configured for real-time sync');
    
    Get.put(AuthenticationRepository());
    Get.put(AnalyticsService());
    Get.put(FirestoreNotificationListener()); // Listen for Firestore notifications
  });

  /// -- Enable Fullscreen Immersive Mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  /// -- Main App Starts here (app.dart) ...
  runApp(const App());
}
