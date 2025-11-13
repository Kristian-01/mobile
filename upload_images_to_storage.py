import os
import re
import firebase_admin
from firebase_admin import credentials, firestore, storage
from pathlib import Path

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

# Image folder paths
image_folders = {
    'BABY_PRODUCTS': r'c:\Users\kristian\img\images_baby_products',
    'FEMININE_CARE': r'c:\Users\kristian\img\images_female_care',
    'FOOD_AND_BEVERAGES': r'c:\Users\kristian\img\images_food_and_beverages',
    'HOUSEHOLD_ITEMS': r'c:\Users\kristian\img\images_household_items',
    'MEDICAL_SUPPLIES': r'c:\Users\kristian\img\images_medical_supplies',
    'MEDICINES': r'c:\Users\kristian\img\images_medicine',
    'OTHERS': r'c:\Users\kristian\img\images_others',
    'PERSONAL_CARE': r'c:\Users\kristian\img\images_personal_care'
}

def normalize_name(name):
    """Normalize product/image name for comparison"""
    # Remove file extensions
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    # Convert to lowercase
    name = name.lower()
    # Remove special characters and extra spaces
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def upload_image_to_storage(local_path, storage_path):
    """Upload image to Firebase Storage and return download URL"""
    try:
        blob = bucket.blob(storage_path)
        blob.upload_from_filename(local_path)
        
        # Make the blob publicly accessible
        blob.make_public()
        
        return blob.public_url
    except Exception as e:
        print(f"    ❌ Error uploading {local_path}: {e}")
        return None

def find_matching_image(product_name, category_images):
    """Find matching image for a product"""
    normalized_product = normalize_name(product_name)
    
    best_match = None
    best_match_score = 0
    
    for image_file, image_path in category_images:
        normalized_image = normalize_name(image_file)
        
        # Exact match
        if normalized_product == normalized_image:
            return image_file, image_path
        
        # Check if product name is in image name or vice versa
        if normalized_product in normalized_image:
            match_score = len(normalized_product) / len(normalized_image)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
        elif normalized_image in normalized_product:
            match_score = len(normalized_image) / len(normalized_product)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
    
    # Return match if score is good enough
    if best_match_score > 0.6:
        return best_match
    
    return None, None

# Step 1: Scan all images
print("📂 Scanning image folders...")
print("-" * 80)

all_images = {}
total_images = 0

for category, folder in image_folders.items():
    images = []
    if os.path.exists(folder):
        for file in os.listdir(folder):
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                full_path = os.path.join(folder, file)
                images.append((file, full_path))
                total_images += 1
        all_images[category] = images
        print(f"  ✅ {category}: {len(images)} images")
    else:
        print(f"  ⚠️  {category}: Folder not found")
        all_images[category] = []

print("-" * 80)
print(f"📊 Total images found: {total_images}")
print("-" * 80)

# Step 2: Get all products from Firestore
print("\n📦 Fetching products from Firestore...")
products_ref = db.collection('Products')
all_products = products_ref.stream()

products_list = []
for doc in all_products:
    product_data = doc.to_dict()
    product_data['doc_id'] = doc.id
    products_list.append(product_data)

print(f"✅ Found {len(products_list)} products in Firestore")
print("-" * 80)

# Step 3: Match products with images and upload
print("\n🔄 Matching products with images and uploading...")
print("=" * 80)

updated_count = 0
no_match_count = 0
products_to_delete = []
upload_errors = []

for i, product in enumerate(products_list, 1):
    product_name = product.get('title', '')
    category_id = product.get('categoryId', '')
    doc_id = product.get('doc_id', '')
    
    print(f"\n[{i}/{len(products_list)}] Processing: {product_name}")
    print(f"  Category: {category_id}")
    
    # Get images for this category
    category_images = all_images.get(category_id, [])
    
    if not category_images:
        print(f"  ⚠️  No images folder for category: {category_id}")
        products_to_delete.append(doc_id)
        no_match_count += 1
        continue
    
    # Find matching image
    image_file, image_path = find_matching_image(product_name, category_images)
    
    if image_file and image_path:
        print(f"  ✅ Matched with: {image_file}")
        
        # Upload to Firebase Storage
        storage_path = f"products/{category_id}/{image_file}"
        print(f"  📤 Uploading to: {storage_path}")
        
        image_url = upload_image_to_storage(image_path, storage_path)
        
        if image_url:
            print(f"  ✅ Uploaded! URL: {image_url[:60]}...")
            
            # Update Firestore
            try:
                db.collection('Products').document(doc_id).update({
                    'thumbnail': image_url,
                    'images': [image_url]
                })
                updated_count += 1
                print(f"  ✅ Updated Firestore")
            except Exception as e:
                print(f"  ❌ Error updating Firestore: {e}")
                upload_errors.append(product_name)
        else:
            print(f"  ❌ Failed to upload image")
            upload_errors.append(product_name)
    else:
        print(f"  ❌ No matching image found")
        products_to_delete.append(doc_id)
        no_match_count += 1

# Step 4: Delete products without images
print("\n" + "=" * 80)
print("🗑️  REMOVING PRODUCTS WITHOUT IMAGES")
print("=" * 80)

if products_to_delete:
    print(f"Found {len(products_to_delete)} products without images")
    
    deleted_count = 0
    for doc_id in products_to_delete:
        try:
            db.collection('Products').document(doc_id).delete()
            deleted_count += 1
        except Exception as e:
            print(f"  ❌ Error deleting product: {e}")
    
    print(f"✅ Deleted {deleted_count} products without images")
else:
    print("✅ All products have images!")

# Final Summary
print("\n" + "=" * 80)
print("🎉 PROCESS COMPLETE!")
print("=" * 80)
print(f"📊 Total products processed: {len(products_list)}")
print(f"✅ Successfully updated: {updated_count}")
print(f"❌ No image match found: {no_match_count}")
print(f"🗑️  Deleted from Firestore: {len(products_to_delete)}")
if upload_errors:
    print(f"⚠️  Upload errors: {len(upload_errors)}")
print("-" * 80)
print(f"📦 Final product count: {len(products_list) - len(products_to_delete)}")
print("=" * 80)
print(f"\n🔗 View at: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("🔗 Storage: https://console.firebase.google.com/project/mobile-e4ddd/storage")
print("=" * 80)
