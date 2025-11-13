# Category Images Setup Guide

## Paano mag-save ng Category Images

Kailangan mo i-save ang 6 na images sa folder na:
```
c:\Projects\capstone\mobile3\assets\icons\categories\
```

## Image Assignments

### 1. **baby-products.png** (Image 1)
- Larawan ng baby onesie, bib, at feeding bottle
- Para sa **Baby Products** category
- Kulay: Light blue at yellow

### 2. **feminine-care.png** (Image 2)
- Pink circle na may female symbol sa kamay
- Para sa **Feminine Care** category
- Kulay: Hot pink/magenta

### 3. **medicines.png** (Image 3)
- Larawan ng pills at tablets
- Para sa **Medicines** category
- Kulay: Light blue at red/pink

### 4. **medical-supplies.png** (Image 4)
- First aid kit/medical bag
- Para sa **Medical Supplies** category
- Kulay: Red/orange

### 5. **personal-care.png** (Image 5)
- Pump bottles at personal care products
- Para sa **Personal Care** category
- Kulay: Light blue

### 6. **others.png** (Image 6)
- Generic boxes/squares
- Para sa **Others** category
- Kulay: Black at blue

## Steps to Complete Setup:

1. **Save the images** na ipinakita sa chat to:
   - `c:\Projects\capstone\mobile3\assets\icons\categories\baby-products.png`
   - `c:\Projects\capstone\mobile3\assets\icons\categories\feminine-care.png`
   - `c:\Projects\capstone\mobile3\assets\icons\categories\medicines.png`
   - `c:\Projects\capstone\mobile3\assets\icons\categories\medical-supplies.png`
   - `c:\Projects\capstone\mobile3\assets\icons\categories\personal-care.png`
   - `c:\Projects\capstone\mobile3\assets\icons\categories\others.png`

2. **Upload categories to Firebase:**
   ```bash
   cd c:\Projects\capstone\mobile3
   python upload_pharmacy_categories.py
   ```

3. **Refresh Flutter assets:**
   ```bash
   flutter pub get
   ```

4. **Restart the app** to see the new category images

## Files Already Updated:

✅ `lib/utils/constants/image_strings.dart` - Added category icon constants
✅ `upload_pharmacy_categories.py` - Script to upload categories to Firestore

## Note:

Ang images na ipinakita sa chat, i-right-click at "Save image as..." tapos i-save sa tamang folder with correct filename.
