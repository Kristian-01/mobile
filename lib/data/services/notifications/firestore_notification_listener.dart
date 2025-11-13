import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../../data/repository/authentication_repository/authentication_repository.dart';

/// Service to listen for Firestore notifications and display them locally
class FirestoreNotificationListener extends GetxService {
  static FirestoreNotificationListener get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notifSub;
  
  // Track last check time to avoid showing old notifications
  DateTime _lastCheckTime = DateTime.now();
  
  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();
    // Start listening when user logs in and stop on logout
    _watchAuthState();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification_icon');

    const DarwinInitializationSettings initializationSettingsDarwin = 
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null && response.payload!.isNotEmpty) {
          Get.toNamed(response.payload!);
        }
      },
    );
  }

  void _watchAuthState() {
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Cancel any previous notifications subscription
      _notifSub?.cancel();
      if (user == null) {
        if (kDebugMode) print('🔕 User signed out. Notification listener stopped.');
        return;
      }
      final userId = user.uid;
      if (kDebugMode) print('🔔 Starting Firestore notification listener for user: $userId');
      _lastCheckTime = DateTime.now();

      _notifSub = _db
          .collection('Notifications')
          .where('recipientIds', arrayContains: userId)
          .limit(20)
          .snapshots()
          .listen((snapshot) {
        if (kDebugMode) print('📥 Received ${snapshot.docChanges.length} notification changes');
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final notification = change.doc.data();
            if (notification != null) {
              _handleNewNotification(notification, change.doc.id);
            }
          }
        }
      }, onError: (error) {
        if (kDebugMode) print('❌ Notification listener error: $error');
      });
    });
  }

  /// Handle new notification from Firestore
  void _handleNewNotification(Map<String, dynamic> notification, String notificationId) {
    try {
      final createdAt = notification['createdAt'];
      DateTime notificationTime;
      
      // Parse timestamp; if missing (serverTimestamp pending), treat as now
      if (createdAt is Timestamp) {
        notificationTime = createdAt.toDate();
      } else {
        notificationTime = DateTime.now();
      }
      
      // Only show notifications created after app start or recent ones
      if (notificationTime.isAfter(_lastCheckTime.subtract(const Duration(minutes: 1)))) {
        final title = notification['title'] ?? 'Notification';
        final body = notification['body'] ?? '';
        final route = notification['route'] ?? '/notification';
        final routeId = notification['routeId'] ?? '';
        
        if (kDebugMode) {
          print('🔔 New notification:');
          print('   - Title: $title');
          print('   - Body: $body');
          print('   - Route: $route');
        }
        
        // Show local notification
        _showLocalNotification(title, body, '$route?id=$routeId');
        
        // Mark as seen
        _markAsSeen(notificationId);
      } else {
        if (kDebugMode) print('⏭️ Skipping old notification');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling notification: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(String title, String body, String payload) async {
    if (kIsWeb) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Mark notification as seen
  Future<void> _markAsSeen(String notificationId) async {
    try {
      final userId = AuthenticationRepository.instance.getUserID;
      
      await _db.collection('Notifications').doc(notificationId).update({
        'seenBy.$userId': FieldValue.serverTimestamp(),
      });
      
      if (kDebugMode) print('✅ Notification marked as seen');
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not mark notification as seen: $e');
    }
  }
}
