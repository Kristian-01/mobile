# Web Push Notifications Setup - Nine27 Pharmacy PWA

## Current Status
✅ Service worker created (`web/firebase-messaging-sw.js`)
✅ Firebase Messaging initialized in `web/index.html`
✅ Cloud Function ready to send FCM push (`functions/notifications/order_notifications.js`)
⏳ **VAPID Key needed to enable web token retrieval**

## Next Steps to Complete Web Push

### Step 1: Get Your Firebase Web Push VAPID Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **mobile-e4ddd**
3. Go to **Project Settings** (gear icon) → **Cloud Messaging** tab
4. Scroll to **Web Push certificates** section
5. If no key exists, click **Generate key pair**
6. Copy the **Key pair** value (starts with `B...`)

### Step 2: Add VAPID Key to Code

Once you have the VAPID key, I'll update:
- `lib/data/services/notifications/notification_service.dart` to use it for web token retrieval
- Enable `getToken()` for web platform

### Step 3: Deploy Cloud Functions (if not deployed)

```bash
cd c:\Projects\capstone\mobile3
firebase deploy --only functions
```

The Cloud Function `sendNotification` will automatically send FCM push messages whenever a new document is created in the `Notifications` collection.

### Step 4: Test Web Push

1. Open PWA in browser
2. Allow notifications when prompted
3. User's web FCM token will be saved to `Users.deviceToken`
4. Update order status or verify prescription on Desktop
5. PWA should receive push notification even when closed/background

## Current Behavior (Without VAPID Key)

- ✅ In-app snackbar notifications work (when PWA is open)
- ❌ Background/closed notifications don't work yet (need VAPID key)

## Tell Cascade

Send the VAPID key and I'll complete the setup immediately:
```
"Here's my VAPID key: B_______________..."
```
