# Nine27 Pharmacy - Full Deployment Checklist

## ✅ Completed Setup

### Mobile App
- [x] Order notifications (pending → processing → shipped → delivered)
- [x] Prescription notifications (verified/declined)
- [x] Firestore notification listener
- [x] Local push notifications
- [x] Upload success dialog
- [x] Pharmacy-only filters (products, categories)

### Desktop Admin
- [x] Notification creation on order status change
- [x] Notification creation on prescription verify/decline
- [x] Email→userId mapping for website prescriptions

### PWA (Web)
- [x] Service worker for offline (`firebase-messaging-sw.js`)
- [x] Firebase Messaging SDK loaded in `index.html`
- [x] In-app snackbar notifications (when open)
- [x] Same pharmacy filters as mobile
- [x] Same UI/UX as mobile (Flutter web)

## ⏳ Pending: Complete Web Push

### What's Needed
1. **VAPID Key** - Get from Firebase Console
   - Path: Project Settings → Cloud Messaging → Web Push certificates
   - Generate if not exists
   - Provide to Cascade to update `notification_service.dart`

2. **Deploy Cloud Functions** (if not deployed)
   ```bash
   cd c:\Projects\capstone\mobile3
   firebase deploy --only functions
   ```

3. **PWA Icons** (optional but recommended)
   - Add icons to `web/icons/` folder
   - Or use mobile app icons as placeholders

## 🚀 How to Build & Deploy PWA

### Build for Web
```bash
cd c:\Projects\capstone\mobile3
flutter build web --release
```

### Deploy to Firebase Hosting (if configured)
```bash
firebase deploy --only hosting
```

### Or Test Locally
```bash
flutter run -d chrome
```

## 📋 Final Testing Steps

### Mobile App
1. Place order → receive "Order Placed" notification
2. Desktop admin updates order to Processing → notification
3. Desktop admin updates to Shipped → notification
4. Desktop admin updates to Delivered → notification
5. Desktop admin verifies prescription → notification
6. Desktop admin declines prescription → notification

### PWA (After VAPID Key Added)
1. Open PWA → allow notifications
2. Check console for web FCM token saved
3. Close PWA
4. Desktop admin triggers order/prescription update
5. PWA should show system notification (even when closed)

## 🔧 Troubleshooting

### Mobile notifications not arriving
- Check: User logged in?
- Check: Firestore `recipientIds` contains user's uid?
- Check: Android notification permission granted?
- Check: `FirestoreNotificationListener` active in logs?

### PWA notifications not arriving (background)
- Check: VAPID key configured in `notification_service.dart`?
- Check: Service worker registered (console logs)?
- Check: Cloud Function deployed (`sendNotification`)?
- Check: User's `deviceToken` saved in Firestore `Users` collection?
- Check: Browser notification permission granted?

### Desktop admin notifications not creating
- Check: Desktop app restarted after `firebase-bridge.js` update?
- Check: Firestore `Notifications` collection has new docs?
- Check: `recipientIds` array contains valid user IDs?

## 📞 Next Steps

Tell Cascade your VAPID key and he'll:
1. Enable web FCM token retrieval
2. Test PWA background notifications
3. Deploy Cloud Functions if needed
4. Generate PWA icons if needed
