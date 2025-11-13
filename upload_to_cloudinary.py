"""
☁️ UPLOAD IMAGES TO CLOUDINARY
================================

This script uploads all local images to Cloudinary and updates Firestore.

REQUIREMENTS:
pip install cloudinary

SETUP:
1. Sign up at cloudinary.com
2. Get your Cloud Name, API Key, and API Secret
3. Fill them in below
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore
import re
from datetime import datetime

try:
    import cloudinary
    import cloudinary.uploader
    from cloudinary.utils import cloudinary_url
except ImportError:
    print("❌ Cloudinary not installed!")
    print("Run: pip install cloudinary")
    exit(1)

# ===================================
# CLOUDINARY CREDENTIALS - FILLED IN!
# ===================================
CLOUDINARY_CLOUD_NAME = "dskjwr7g4"
CLOUDINARY_API_KEY = "665786365357986"
CLOUDINARY_API_SECRET = "NMMdgKxtdqvgfRENMtmFgqB8BbM"

# ===================================
# Initialize Cloudinary
# ===================================
cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True
)

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firebase!")
print("☁️  Connected to Cloudinary!")
print("=" * 80)

# Image folder paths
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

# Firestore category mapping
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
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', filename, flags=re.IGNORECASE)
    name = name.lower()
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def upload_to_cloudinary(local_path, cloudinary_folder, filename):
    """Upload single image to Cloudinary"""
    try:
        # Upload with public_id to organize in folders
        public_id = f"product_images/{cloudinary_folder}/{os.path.splitext(filename)[0]}"
        
        result = cloudinary.uploader.upload(
            local_path,
            public_id=public_id,
            overwrite=True,
            resource_type="image",
            folder=f"product_images/{cloudinary_folder}"
        )
        
        # Get the URL
        url = result['secure_url']
        return url
        
    except Exception as e:
        print(f"    ❌ Upload failed: {e}")
        return None

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

def upload_all_images(all_images):
    """Upload all images to Cloudinary"""
    print("\n" + "=" * 80)
    print("☁️  UPLOADING TO CLOUDINARY")
    print("=" * 80)
    
    uploaded_images = {}
    total_uploaded = 0
    total_failed = 0
    
    for category, images in all_images.items():
        if not images:
            continue
            
        print(f"\n📂 Uploading {category}...")
        print("-" * 80)
        
        category_uploads = {}
        
        for img in images:
            filename = img['filename']
            local_path = img['path']
            
            print(f"  ⬆️  {filename[:50]}...", end=" ", flush=True)
            
            url = upload_to_cloudinary(local_path, category, filename)
            
            if url:
                print("✅")
                category_uploads[img['normalized']] = {
                    'filename': filename,
                    'url': url
                }
                total_uploaded += 1
            else:
                print("❌")
                total_failed += 1
        
        uploaded_images[category] = category_uploads
        print(f"  📊 {len(category_uploads)} images uploaded")
    
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
    
    # Fuzzy match
    for norm_name, img_data in category_images.items():
        if normalized_product in norm_name or norm_name in normalized_product:
            if len(normalized_product) > 5:
                return img_data
    
    return None

def update_products_in_firestore(uploaded_images):
    """Update all products with Cloudinary URLs"""
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
            print(f"  ⚠️  No category: {product_name} ({category_id})")
            stats['no_category'] += 1
            continue
        
        # Find matching image
        category_images = uploaded_images.get(category_folder, {})
        matched_image = match_product_to_image(product_name, category_images)
        
        if matched_image:
            cloudinary_url = matched_image['url']
            
            doc.reference.update({
                'thumbnail': cloudinary_url,
                'images': [cloudinary_url],
                'updatedAt': datetime.now()
            })
            
            print(f"  ✅ {product_name[:50]}")
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
    """Delete products without images"""
    if not products_to_delete:
        print("\n✅ No products to delete!")
        return 0
    
    print("\n" + "=" * 80)
    print("🗑️  PRODUCTS WITHOUT IMAGES")
    print("=" * 80)
    
    for prod in products_to_delete:
        print(f"  - {prod['name']} ({prod['category']})")
    
    print("\n" + "=" * 80)
    response = input(f"⚠️  Delete {len(products_to_delete)} products? (yes/no): ")
    
    if response.lower() in ['yes', 'y']:
        deleted = 0
        for prod in products_to_delete:
            try:
                db.collection('products').document(prod['id']).delete()
                deleted += 1
            except Exception as e:
                print(f"  ❌ Failed: {prod['name']}")
        
        print(f"\n✅ Deleted {deleted} products")
        return deleted
    else:
        print("\n❌ Deletion cancelled")
        return 0

def main():
    """Main execution"""
    
    # Check if credentials are set
    if CLOUDINARY_CLOUD_NAME == "YOUR_CLOUD_NAME":
        print("\n" + "=" * 80)
        print("❌ ERROR: Cloudinary credentials not set!")
        print("=" * 80)
        print("\n📋 To fix this:")
        print("1. Go to: https://cloudinary.com")
        print("2. Sign up or login")
        print("3. Copy your credentials from dashboard:")
        print("   - Cloud Name")
        print("   - API Key")
        print("   - API Secret")
        print("\n4. Edit this file and fill in:")
        print("   CLOUDINARY_CLOUD_NAME = 'your-cloud-name'")
        print("   CLOUDINARY_API_KEY = 'your-api-key'")
        print("   CLOUDINARY_API_SECRET = 'your-api-secret'")
        print("\n5. Run script again")
        print("\n" + "=" * 80)
        return
    
    print("\n" + "=" * 80)
    print("🚀 CLOUDINARY UPLOAD STARTING")
    print("=" * 80)
    print(f"Cloud Name: {CLOUDINARY_CLOUD_NAME}")
    
    # Step 1: Scan images
    all_images = get_all_local_images()
    
    # Step 2: Upload to Cloudinary
    uploaded_images = upload_all_images(all_images)
    
    # Step 3: Update Firestore
    stats = update_products_in_firestore(uploaded_images)
    
    # Step 4: Summary
    print("\n" + "=" * 80)
    print("📊 SUMMARY")
    print("=" * 80)
    print(f"Total products: {stats['total']}")
    print(f"✅ Updated: {stats['updated']}")
    print(f"❌ No image: {stats['no_image']}")
    
    # Step 5: Delete if needed
    if stats['to_delete']:
        deleted = delete_products_without_images(stats['to_delete'])
    
    print("\n" + "=" * 80)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 80)
    print("\n💡 Your images are now on Cloudinary!")
    print(f"🔗 View at: https://cloudinary.com/console/c-{CLOUDINARY_CLOUD_NAME}/media_library")
    print("\n✅ Website and mobile app should now show all images!")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Upload cancelled")
    except Exception as e:
        print(f"\n\n💥 ERROR: {e}")
        import traceback
        traceback.print_exc()
