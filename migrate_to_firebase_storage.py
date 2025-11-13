"""
🔥 MIGRATE IMAGES TO FIREBASE STORAGE
====================================

This script will:
1. Check all local images
2. Upload to Firebase Storage
3. Update Firestore with Firebase URLs  
4. Remove products without images
5. Display summary
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore, storage
from pathlib import Path
import re
from datetime import datetime

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'mobile-e4ddd.appspot.com'
    })

db = firestore.client()
bucket = storage.bucket()

print("🔥 Connected to Firebase!")
print("=" * 80)

# Image folder paths (reorganized categories)
IMAGE_FOLDERS = {
    'baby_products': r'c:\Users\kristian\img\images_baby_products',
    'female_care': r'c:\Users\kristian\img\images_female_care',
    'food_and_beverages': r'c:\Users\kristian\img\images_food_and_beverages',
    'household_items': r'c:\Users\kristian\img\images_household_items',
    'medical_supplies': r'c:\Users\kristian\img\images_medical_supplies',
    'medicine': r'c:\Users\kristian\img\images_medicine',
    'others': r'c:\Users\kristian\img\images_others',
    'personal_care': r'c:\Users\kristian\img\images_personal_care'
}

# Firestore category IDs mapping
CATEGORY_MAPPING = {
    'baby_products': 'BABY_PRODUCTS',
    'female_care': 'FEMININE_CARE',
    'food_and_beverages': 'FOOD_AND_BEVERAGES',
    'household_items': 'HOUSEHOLD_ITEMS',
    'medical_supplies': 'MEDICAL_SUPPLIES',
    'medicine': 'MEDICINES',
    'others': 'OTHERS',
    'personal_care': 'PERSONAL_CARE'
}

def normalize_filename(filename):
    """Normalize filename for comparison"""
    # Remove extension
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', filename, flags=re.IGNORECASE)
    # Convert to lowercase
    name = name.lower()
    # Replace special characters with spaces
    name = re.sub(r'[^\w\s]', ' ', name)
    # Remove extra spaces
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def get_all_local_images():
    """Scan all local image folders"""
    all_images = {}
    total_count = 0
    
    print("\n📁 Scanning local image folders...")
    print("-" * 80)
    
    for category, folder_path in IMAGE_FOLDERS.items():
        images = []
        if os.path.exists(folder_path):
            for file in os.listdir(folder_path):
                if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                    images.append({
                        'filename': file,
                        'path': os.path.join(folder_path, file),
                        'normalized': normalize_filename(file)
                    })
            images.sort(key=lambda x: x['filename'])
        
        all_images[category] = images
        total_count += len(images)
        print(f"  ✅ {category}: {len(images)} images")
    
    print(f"\n📊 Total local images: {total_count}")
    return all_images

def upload_image_to_storage(local_path, firebase_path):
    """Upload single image to Firebase Storage"""
    try:
        blob = bucket.blob(firebase_path)
        blob.upload_from_filename(local_path)
        blob.make_public()
        
        # Get public URL
        url = blob.public_url
        return url
    except Exception as e:
        print(f"    ❌ Upload failed: {e}")
        return None

def upload_all_images_to_firebase(all_images):
    """Upload all images to Firebase Storage"""
    print("\n" + "=" * 80)
    print("📤 UPLOADING IMAGES TO FIREBASE STORAGE")
    print("=" * 80)
    
    uploaded_images = {}
    total_uploaded = 0
    total_failed = 0
    
    for category, images in all_images.items():
        print(f"\n📂 Uploading {category}...")
        print("-" * 80)
        
        category_uploads = {}
        
        for img in images:
            filename = img['filename']
            local_path = img['path']
            
            # Firebase Storage path
            firebase_path = f"product_images/{category}/{filename}"
            
            print(f"  ⬆️  {filename}...", end=" ")
            
            url = upload_image_to_storage(local_path, firebase_path)
            
            if url:
                print("✅")
                category_uploads[img['normalized']] = {
                    'filename': filename,
                    'url': url,
                    'firebase_path': firebase_path
                }
                total_uploaded += 1
            else:
                print("❌")
                total_failed += 1
        
        uploaded_images[category] = category_uploads
        print(f"  📊 {len(category_uploads)} images uploaded to {category}")
    
    print("\n" + "=" * 80)
    print(f"✅ Upload complete: {total_uploaded} uploaded, {total_failed} failed")
    print("=" * 80)
    
    return uploaded_images

def match_product_to_image(product_name, category_images):
    """Find matching image for a product"""
    normalized_product = normalize_filename(product_name)
    
    # Exact match first
    if normalized_product in category_images:
        return category_images[normalized_product]
    
    # Fuzzy match - check if product name is in image name
    for norm_name, img_data in category_images.items():
        if normalized_product in norm_name or norm_name in normalized_product:
            # More strict for short names
            if len(normalized_product) > 5:
                return img_data
    
    return None

def update_products_in_firestore(uploaded_images):
    """Update all products with Firebase Storage URLs"""
    print("\n" + "=" * 80)
    print("🔄 UPDATING PRODUCTS IN FIRESTORE")
    print("=" * 80)
    
    products_ref = db.collection('products')
    all_products = products_ref.get()
    
    stats = {
        'total': 0,
        'updated': 0,
        'no_image': 0,
        'no_category': 0,
        'to_delete': []
    }
    
    for doc in all_products:
        stats['total'] += 1
        product = doc.to_dict()
        product_name = product.get('name', product.get('title', 'Unknown'))
        category_id = product.get('categoryId', '').upper()
        
        # Find category folder
        category_folder = None
        for folder, firestore_cat in CATEGORY_MAPPING.items():
            if firestore_cat == category_id:
                category_folder = folder
                break
        
        if not category_folder:
            print(f"  ⚠️  No category mapping: {product_name} ({category_id})")
            stats['no_category'] += 1
            continue
        
        # Find matching image
        category_images = uploaded_images.get(category_folder, {})
        matched_image = match_product_to_image(product_name, category_images)
        
        if matched_image:
            # Update product with Firebase Storage URL
            firebase_url = matched_image['url']
            
            doc.reference.update({
                'thumbnail': firebase_url,
                'images': [firebase_url],
                'updatedAt': datetime.now()
            })
            
            print(f"  ✅ Updated: {product_name}")
            stats['updated'] += 1
        else:
            print(f"  ❌ NO IMAGE: {product_name}")
            stats['no_image'] += 1
            stats['to_delete'].append({
                'id': doc.id,
                'name': product_name,
                'category': category_id
            })
    
    return stats

def delete_products_without_images(products_to_delete):
    """Delete products that don't have images"""
    if not products_to_delete:
        print("\n✅ No products to delete!")
        return 0
    
    print("\n" + "=" * 80)
    print("🗑️  PRODUCTS WITHOUT IMAGES")
    print("=" * 80)
    
    for prod in products_to_delete:
        print(f"  - {prod['name']} ({prod['category']})")
    
    print("\n" + "=" * 80)
    response = input(f"⚠️  Delete {len(products_to_delete)} products without images? (yes/no): ")
    
    if response.lower() in ['yes', 'y']:
        deleted = 0
        for prod in products_to_delete:
            try:
                db.collection('products').document(prod['id']).delete()
                print(f"  ✅ Deleted: {prod['name']}")
                deleted += 1
            except Exception as e:
                print(f"  ❌ Failed to delete {prod['name']}: {e}")
        
        print(f"\n✅ Deleted {deleted} products")
        return deleted
    else:
        print("\n❌ Deletion cancelled")
        return 0

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 STARTING MIGRATION TO FIREBASE STORAGE")
    print("=" * 80)
    
    # Step 1: Scan local images
    all_images = get_all_local_images()
    
    # Step 2: Upload to Firebase Storage
    uploaded_images = upload_all_images_to_firebase(all_images)
    
    # Step 3: Update Firestore products
    stats = update_products_in_firestore(uploaded_images)
    
    # Step 4: Show summary
    print("\n" + "=" * 80)
    print("📊 MIGRATION SUMMARY")
    print("=" * 80)
    print(f"Total products: {stats['total']}")
    print(f"✅ Updated with images: {stats['updated']}")
    print(f"❌ No image found: {stats['no_image']}")
    print(f"⚠️  No category: {stats['no_category']}")
    
    # Step 5: Delete products without images
    if stats['to_delete']:
        deleted = delete_products_without_images(stats['to_delete'])
        print(f"\n🗑️  Final deleted: {deleted}")
    
    print("\n" + "=" * 80)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 80)
    print("\n💡 Next steps:")
    print("  1. Test website - images should load from Firebase")
    print("  2. Test mobile app - images should load from Firebase")
    print("  3. Verify all products have correct images")
    print("\n🔗 Firebase Storage: https://console.firebase.google.com/project/mobile-e4ddd/storage")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Migration cancelled by user")
    except Exception as e:
        print(f"\n\n💥 ERROR: {e}")
        import traceback
        traceback.print_exc()
