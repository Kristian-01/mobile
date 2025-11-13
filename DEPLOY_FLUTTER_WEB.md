# 🚀 Deploy Flutter Web App to Firebase

## Quick Deploy Commands

### Step 1: Build Flutter Web App
```bash
cd c:\Projects\capstone\mobile3
flutter build web --release
```

### Step 2: Deploy to Firebase
```bash
firebase deploy --only hosting
```

## Expected Result
- **URL**: https://mobile-e4ddd.web.app
- **Type**: Flutter Progressive Web App
- **Features**: Full mobile app functionality in browser

## Update Website Link

After deployment, update the website's main.html:

**File**: `c:\Projects\capstone\website\designnijess - Copy - Copy\main.html`

**Line 394**: Change to deployed URL
```javascript
const webAppUrl = 'https://mobile-e4ddd.web.app';
```

## Test After Deployment
1. Visit: https://mobile-e4ddd.web.app
2. Should see Nine27 Pharmacy Flutter app
3. Can "Install App" from browser (PWA feature)

## Alternative: Use Same Domain
If you want web app on same domain as website:
- Copy `build/web/*` to `website/apps/webapp/`
- Then use: `const webAppUrl = '/apps/webapp/';`
