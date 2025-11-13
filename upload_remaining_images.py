import os
import re
import csv
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import base64
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# ImgBB API Configuration
IMGBB_API_KEY = "e0ced2c1a8ca604b7780f01b08b00f29"
IMGBB_UPLOAD_URL = "https://api.imgbb.com/1/upload"

# Concurrent upload settings
MAX_WORKERS = 5  # Reduced to avoid rate limiting
RETRY_ATTEMPTS = 2

# Thread-safe counters
upload_lock = Lock()
upload_count = 0
error_count = 0
skip_count = 0

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
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    name = name.lower()
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def upload_to_imgbb(image_path, image_name, retry=0):
    """Upload image to ImgBB and return URL"""
    global upload_count, error_count
    
    try:
        with open(image_path, 'rb') as file:
            image_data = base64.b64encode(file.read()).decode('utf-8')
            
            payload = {
                'key': IMGBB_API_KEY,
                'image': image_data,
                'name': image_name
            }
            
            response = requests.post(IMGBB_UPLOAD_URL, data=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('success'):
                    with upload_lock:
                        upload_count += 1
                    return result['data']['url']
            
            if retry < RETRY_ATTEMPTS:
                time.sleep(2)
                return upload_to_imgbb(image_path, image_name, retry + 1)
            
            with upload_lock:
                error_count += 1
            return None
                
    except Exception as e:
        if retry < RETRY_ATTEMPTS:
            time.sleep(2)
            return upload_to_imgbb(image_path, image_name, retry + 1)
        with upload_lock:
            error_count += 1
        return None

def find_matching_image(product_name, category_images):
    """Find matching image for a product"""
    normalized_product = normalize_name(product_name)
    
    best_match = None
    best_match_score = 0
    
    for image_file, image_path in category_images:
        normalized_image = normalize_name(image_file)
        
        if normalized_product == normalized_image:
            return image_file, image_path
        
        if normalized_product in normalized_image:
            match_score = len(normalized_product) / max(len(normalized_image), 1)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
        elif normalized_image in normalized_product:
            match_score = len(normalized_image) / max(len(normalized_product), 1)
            if match_score > best_match_score:
                best_match = (image_file, image_path)
                best_match_score = match_score
    
    if best_match_score > 0.6:
        return best_match
    
    return None, None

# Step 1: Get all images
print("📂 Scanning image folders...")
print("-" * 80)

all_images = {}
for category, folder in image_folders.items():
    images = []
    if os.path.exists(folder):
        for file in os.listdir(folder):
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                images.append((file, os.path.join(folder, file)))
        all_images[category] = images
        print(f"  ✅ {category}: {len(images)} images")

print("-" * 80)

# Step 2: Get all products from Firestore
print("\n📦 Fetching products from Firestore...")
products_ref = db.collection('Products')
all_products = []

try:
    last_doc = None
    while True:
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(100)
        else:
            query = products_ref.order_by('__name__').limit(100)
        
        docs = list(query.stream())
        if not docs:
            break
        
        for doc in docs:
            data = doc.to_dict()
            data['doc_id'] = doc.id
            all_products.append(data)
        
        last_doc = docs[-1]
        print(f"  Loaded {len(all_products)} products...")
        time.sleep(0.5)
        
except Exception as e:
    print(f"❌ Error loading products: {e}")

print(f"✅ Total products: {len(all_products)}")
print("-" * 80)

# Step 3: Match products with images
print("\n🔍 Matching products with images...")
print("-" * 80)

product_image_map = {}

for product in all_products:
    product_name = product.get('title', '')
    category_id = product.get('categoryId', '')
    doc_id = product.get('doc_id', '')
    
    category_images = all_images.get(category_id, [])
    image_file, image_path = find_matching_image(product_name, category_images)
    
    if image_file and image_path:
        product_image_map[doc_id] = {
            'product_name': product_name,
            'image_file': image_file,
            'image_path': image_path,
            'category': category_id
        }

print(f"✅ Matched {len(product_image_map)} products with images")
print("-" * 80)

# Step 4: Upload images to ImgBB
print(f"\n📤 Uploading images to ImgBB (using {MAX_WORKERS} workers)...")
print("=" * 80)
print("⚠️  This may take 10-20 minutes...")
print("-" * 80)

uploaded_urls = {}
start_time = time.time()

def upload_single_image(doc_id, info):
    global skip_count
    
    image_file = info['image_file']
    image_path = info['image_path']
    
    # Check if already uploaded (avoid duplicates)
    if image_file in uploaded_urls:
        with upload_lock:
            skip_count += 1
        return doc_id, uploaded_urls[image_file], True
    
    # Upload
    url = upload_to_imgbb(image_path, image_file)
    
    if url:
        uploaded_urls[image_file] = url
        return doc_id, url, False
    else:
        return doc_id, None, False

with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    future_to_doc = {
        executor.submit(upload_single_image, doc_id, info): doc_id
        for doc_id, info in product_image_map.items()
    }
    
    for i, future in enumerate(as_completed(future_to_doc), 1):
        doc_id = future_to_doc[future]
        try:
            doc_id, url, was_skipped = future.result()
            
            if url:
                product_image_map[doc_id]['url'] = url
            
            if i % 50 == 0:
                elapsed = time.time() - start_time
                rate = i / elapsed
                remaining = (len(product_image_map) - i) / rate if rate > 0 else 0
                print(f"📊 [{i}/{len(product_image_map)}] | "
                      f"✅ {upload_count} | ⏭️ {skip_count} | ❌ {error_count} | "
                      f"⏱️ ETA: {int(remaining/60)}m {int(remaining%60)}s")
                
        except Exception as e:
            print(f"  ❌ Error: {e}")

elapsed = time.time() - start_time
print(f"\n✅ Upload phase complete in {int(elapsed/60)}m {int(elapsed%60)}s!")
print(f"   Uploaded: {upload_count} | Skipped: {skip_count} | Failed: {error_count}")
print("-" * 80)

# Step 5: Update Firestore
print("\n🔄 Updating Firestore with image URLs...")
print("-" * 80)

updated_count = 0
batch = db.batch()
batch_count = 0

for doc_id, info in product_image_map.items():
    if 'url' in info:
        url = info['url']
        doc_ref = db.collection('Products').document(doc_id)
        
        batch.update(doc_ref, {
            'thumbnail': url,
            'images': [url],
            'hasImage': True
        })
        
        updated_count += 1
        batch_count += 1
        
        if batch_count >= 500:
            batch.commit()
            batch = db.batch()
            batch_count = 0
            print(f"  ⏳ Updated {updated_count} products...")
            time.sleep(1)

if batch_count > 0:
    batch.commit()

print(f"✅ Updated {updated_count} products in Firestore")

# Final Summary
print("\n" + "=" * 80)
print("🎉 COMPLETE!")
print("=" * 80)
print(f"📤 Images uploaded to ImgBB: {upload_count}")
print(f"✅ Products updated with real images: {updated_count}")
print(f"❌ Failed uploads: {error_count}")
print(f"📦 Products with placeholders: {len(all_products) - updated_count}")
print("=" * 80)
print(f"\n🔗 View: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)

if updated_count > 0:
    print(f"\n✅ Your Flutter app now shows {updated_count} products with REAL images!")
if error_count > 0:
    print(f"\n⚠️  {error_count} images failed (likely rate limit). Run again tomorrow for remaining.")

print("=" * 80)
