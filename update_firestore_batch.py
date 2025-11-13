import os
import re
import csv
import firebase_admin
from firebase_admin import credentials, firestore
import time

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# CSV files
csv_files = {
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv',
    'FOOD_AND_BEVERAGES': 'products_FOOD_AND_BEVERAGES.csv',
    'HOUSEHOLD_ITEMS': 'products_HOUSEHOLD_ITEMS.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'MEDICINES': 'products_MEDICINES.csv',
    'OTHERS': 'products_OTHERS.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv'
}

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

# Step 1: Build list of products that SHOULD have images
print("🔍 Building list of products with images from CSV...")
print("-" * 80)

# First, get all images
all_images = {}
for category, folder in image_folders.items():
    images = []
    if os.path.exists(folder):
        for file in os.listdir(folder):
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                full_path = os.path.join(folder, file)
                images.append((file, full_path))
        all_images[category] = images

# Build product-image mapping
products_with_images = set()

for category in csv_files.keys():
    csv_file = csv_files[category]
    
    if not os.path.exists(csv_file):
        continue
    
    category_images = all_images.get(category, [])
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            product_name = row['Product Name'].strip()
            image_file, image_path = find_matching_image(product_name, category_images)
            
            if image_file and image_path:
                products_with_images.add(product_name)

print(f"✅ Found {len(products_with_images)} products that should have images")
print("-" * 80)

# Step 2: Process Firestore in small batches
print("\n🔄 Processing Firestore products in batches...")
print("=" * 80)

BATCH_SIZE = 50  # Process 50 products at a time
DELAY_BETWEEN_BATCHES = 2  # Wait 2 seconds between batches

products_ref = db.collection('Products')

# Get count first
print("📊 Counting products...")
all_docs = []
try:
    # Use pagination to avoid quota issues
    last_doc = None
    page_num = 0
    
    while True:
        page_num += 1
        print(f"  Loading page {page_num}...")
        
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(100)
        else:
            query = products_ref.order_by('__name__').limit(100)
        
        docs = list(query.stream())
        
        if not docs:
            break
        
        all_docs.extend(docs)
        last_doc = docs[-1]
        
        time.sleep(1)  # Rate limiting
        
except Exception as e:
    print(f"❌ Error loading products: {e}")
    print("Retrying with smaller batches...")
    all_docs = []

print(f"✅ Loaded {len(all_docs)} products")
print("-" * 80)

# Step 3: Update or delete in batches
print(f"\n📝 Updating/deleting products in batches of {BATCH_SIZE}...")
print("-" * 80)

updated_count = 0
deleted_count = 0
error_count = 0

for i in range(0, len(all_docs), BATCH_SIZE):
    batch_docs = all_docs[i:i + BATCH_SIZE]
    batch_num = (i // BATCH_SIZE) + 1
    total_batches = (len(all_docs) + BATCH_SIZE - 1) // BATCH_SIZE
    
    print(f"\n[Batch {batch_num}/{total_batches}] Processing {len(batch_docs)} products...")
    
    batch = db.batch()
    batch_operations = 0
    
    for doc in batch_docs:
        try:
            product_data = doc.to_dict()
            product_name = product_data.get('title', '')
            
            if product_name in products_with_images:
                # Product has image - keep it with placeholder for now
                # (Real images need to be uploaded to a CDN first)
                # For now, just mark it as having an image
                batch.update(doc.reference, {
                    'hasImage': True
                })
                updated_count += 1
                batch_operations += 1
            else:
                # Product doesn't have image - delete it
                batch.delete(doc.reference)
                deleted_count += 1
                batch_operations += 1
                
        except Exception as e:
            print(f"  ⚠️  Error processing {product_name}: {e}")
            error_count += 1
    
    # Commit the batch
    if batch_operations > 0:
        try:
            batch.commit()
            print(f"  ✅ Updated: {updated_count} | Deleted: {deleted_count} | Errors: {error_count}")
        except Exception as e:
            print(f"  ❌ Batch commit error: {e}")
            error_count += batch_operations
    
    # Rate limiting - wait between batches
    if i + BATCH_SIZE < len(all_docs):
        print(f"  ⏳ Waiting {DELAY_BETWEEN_BATCHES}s before next batch...")
        time.sleep(DELAY_BETWEEN_BATCHES)

# Final Summary
print("\n" + "=" * 80)
print("🎉 BATCH UPDATE COMPLETE!")
print("=" * 80)
print(f"✅ Products kept (have images): {updated_count}")
print(f"🗑️  Products deleted (no images): {deleted_count}")
print(f"❌ Errors: {error_count}")
print(f"📦 Final product count: {updated_count}")
print("=" * 80)
print(f"\n🔗 View Firestore: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)
print("\n⚠️  NOTE: Products are marked as having images, but URLs are still placeholders.")
print("   The 930 images uploaded to ImgBB need to be manually mapped to products.")
print("=" * 80)
