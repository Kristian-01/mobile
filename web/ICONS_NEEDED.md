# PWA Icons Missing

The `web/icons/` folder is empty but `manifest.json` references:
- Icon-192.png (192x192)
- Icon-512.png (512x512)
- Icon-maskable-192.png (192x192)
- Icon-maskable-512.png (512x512)

## Options:

1. **Use your existing mobile app icons**
   - Copy from `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` to `web/icons/Icon-512.png`
   - Resize to 192x192 for Icon-192.png

2. **Generate new icons**
   - Use your pharmacy logo/branding
   - Recommended tool: https://www.pwabuilder.com/imageGenerator
   - Or I can create placeholder icons if you send me your logo

3. **Temporary fix**
   - Use Flutter's default icons (copy from a fresh Flutter web project)

Would you like me to:
- Create placeholder blue icons with "N27" text?
- Wait for you to provide your logo/branding?
