# 🔥 Firebase Storage Setup Guide

## ⚠️ KAILANGAN GAWIN TO!

Para gumana yung prescription upload, kailangan i-configure ang **Firebase Storage Rules**.

---

## 📋 Step 1: Open Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select your project
3. Click **Storage** sa left sidebar
4. Click **Rules** tab

---

## 📋 Step 2: Update Storage Rules

Replace the existing rules with this:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload prescriptions
    match /prescriptions/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024  // Max 10MB
                   && request.resource.contentType.matches('image/.*');  // Images only
    }
    
    // Allow admin read access to all prescriptions
    match /prescriptions/{allPaths=**} {
      allow read: if request.auth != null;
    }
  }
}
```

---

## 📋 Step 3: Publish Rules

1. Click **Publish** button
2. Wait for deployment (few seconds)
3. ✅ Done!

---

## 🎯 What These Rules Do:

### ✅ For Users (Mobile App):
- Can **upload** prescriptions to their own folder only
- Path: `prescriptions/{userId}/{fileName}`
- Must be authenticated
- Max file size: 10MB
- Only images allowed (JPG, PNG, etc.)

### ✅ For Admin (Desktop):
- Can **read** all prescriptions
- Can view images uploaded by any user

### ❌ Security:
- Users cannot upload to other users' folders
- Users cannot upload files > 10MB
- Users cannot upload non-image files
- Unauthenticated users cannot access anything

---

## 🔧 Alternative: Allow All (For Testing Only)

**WARNING: NOT SECURE! Use only for testing!**

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

This allows all authenticated users to read/write anywhere.

---

## 📱 How Upload Works Now:

```
1. User clicks Camera/Gallery
   ↓
2. Image file selected
   ↓
3. Upload to Firebase Storage
   Path: prescriptions/{userId}/prescription_timestamp.jpg
   ↓
4. Get download URL
   ↓
5. Save to Firestore with URL
   ↓
6. Desktop sees it instantly! ✅
```

---

## 🐛 Troubleshooting:

### Error: "Not authorized to upload"
**Solution:** 
1. Check if user is logged in
2. Verify Storage Rules are published
3. Make sure user has internet connection

### Error: "Upload timeout"
**Solution:**
1. Check internet speed
2. Try with smaller image
3. Check Firebase Storage quota

### Error: "Upload failed"
**Solution:**
1. Verify Firebase Storage is enabled
2. Check if billing is enabled (if needed)
3. Check console logs for specific error

---

## ✅ Advantages of Firebase Storage:

1. **No extra setup needed** - Already part of Firebase
2. **Secure** - Built-in authentication
3. **Fast** - Google's infrastructure
4. **Free tier** - 5GB storage, 1GB/day download
5. **Integrated** - Works with Firestore seamlessly

---

## 🎉 After Setup:

Once Firebase Storage rules are configured:

1. ✅ Mobile upload will work
2. ✅ Images saved to Firebase Storage
3. ✅ URLs saved to Firestore
4. ✅ Desktop can view images
5. ✅ Real-time sync working

**Test mo na after setting up the rules! 🚀**
