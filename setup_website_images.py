import os
import re
import csv
import shutil
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

# Paths
IMAGE_SOURCE_FOLDERS = {
    'BABY_PRODUCTS': r'c:\Users\kristian\img\images_baby_products',
    'FEMININE_CARE': r'c:\Users\kristian\img\images_female_care',
    'FOOD_AND_BEVERAGES': r'c:\Users\kristian\img\images_food_and_beverages',
    'HOUSEHOLD_ITEMS': r'c:\Users\kristian\img\images_household_items',
    'MEDICAL_SUPPLIES': r'c:\Users\kristian\img\images_medical_supplies',
    'MEDICINES': r'c:\Users\kristian\img\images_medicine',
    'OTHERS': r'c:\Users\kristian\img\images_others',
    'PERSONAL_CARE': r'c:\Users\kristian\img\images_personal_care'
}

WEBSITE_FOLDER = r'c:\Projects\capstone\website\designnijess - Copy - Copy'
IMAGES_DEST = os.path.join(WEBSITE_FOLDER, 'product_images')

# Your website domain (update this later when deployed)
# For now using localhost for testing
BASE_URL = "http://localhost:8080/product_images"  # Update when deployed

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

# Step 1: Create destination folders
print("📁 Creating website image folders...")
print("-" * 80)

if not os.path.exists(IMAGES_DEST):
    os.makedirs(IMAGES_DEST)
    print(f"  ✅ Created: {IMAGES_DEST}")

for category in IMAGE_SOURCE_FOLDERS.keys():
    category_dest = os.path.join(IMAGES_DEST, category.lower())
    if not os.path.exists(category_dest):
        os.makedirs(category_dest)
        print(f"  ✅ Created: {category.lower()}/")

print("-" * 80)

# Step 2: Scan and copy images
print("\n📸 Copying images to website folder...")
print("-" * 80)

all_images = {}
copied_count = 0

for category, source_folder in IMAGE_SOURCE_FOLDERS.items():
    if not os.path.exists(source_folder):
        print(f"  ⚠️  Source not found: {category}")
        continue
    
    category_dest = os.path.join(IMAGES_DEST, category.lower())
    images = []
    
    for file in os.listdir(source_folder):
        if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
            source_path = os.path.join(source_folder, file)
            dest_path = os.path.join(category_dest, file)
            
            # Copy image
            try:
                shutil.copy2(source_path, dest_path)
                images.append((file, dest_path))
                copied_count += 1
            except Exception as e:
                print(f"  ❌ Error copying {file}: {e}")
    
    all_images[category] = images
    print(f"  ✅ {category}: {len(images)} images copied")

print(f"\n✅ Total images copied: {copied_count}")
print("-" * 80)

# Step 3: Get all products from Firestore
print("\n📦 Loading products from Firestore...")
print("-" * 80)

all_products = []

try:
    last_doc = None
    while True:
        if last_doc:
            query = db.collection('Products').order_by('__name__').start_after(last_doc).limit(100)
        else:
            query = db.collection('Products').order_by('__name__').limit(100)
        
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
    print(f"❌ Error: {e}")

print(f"✅ Total products: {len(all_products)}")
print("-" * 80)

# Step 4: Match products with images and update
print("\n🔄 Updating products with image URLs...")
print("-" * 80)

updated_count = 0
no_image_count = 0
batch = db.batch()
batch_count = 0

for product in all_products:
    product_name = product.get('title', '')
    category_id = product.get('categoryId', '')
    doc_id = product.get('doc_id', '')
    
    # Find matching image
    category_images = all_images.get(category_id, [])
    image_file, image_path = find_matching_image(product_name, category_images)
    
    if image_file:
        # Build URL
        image_url = f"{BASE_URL}/{category_id.lower()}/{image_file}"
        
        # Update product
        doc_ref = db.collection('Products').document(doc_id)
        batch.update(doc_ref, {
            'thumbnail': image_url,
            'images': [image_url],
            'hasImage': True
        })
        
        updated_count += 1
        batch_count += 1
        
        # Commit every 500
        if batch_count >= 500:
            batch.commit()
            batch = db.batch()
            batch_count = 0
            print(f"  ⏳ Updated {updated_count} products...")
            time.sleep(1)
    else:
        no_image_count += 1

# Commit remaining
if batch_count > 0:
    batch.commit()

print(f"✅ Updated {updated_count} products")
print(f"⚠️  {no_image_count} products have no matching images")
print("-" * 80)

# Step 5: Create simple web server script
print("\n📝 Creating web server script...")
print("-" * 80)

server_script = os.path.join(WEBSITE_FOLDER, 'serve_images.py')

with open(server_script, 'w') as f:
    f.write('''"""
Simple HTTP Server to serve product images
Run this to test images locally before deploying
"""

import http.server
import socketserver
import os

PORT = 8080
DIRECTORY = r"''' + WEBSITE_FOLDER + '''"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Add CORS headers for cross-origin requests (Flutter app)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

os.chdir(DIRECTORY)

with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"✅ Server running at http://localhost:{PORT}")
    print(f"📂 Serving files from: {DIRECTORY}")
    print(f"\\n🖼️  Test image URLs:")
    print(f"   http://localhost:{PORT}/product_images/medicines/[filename]")
    print(f"\\n⚠️  Keep this running while testing your Flutter app!")
    print(f"   Press Ctrl+C to stop\\n")
    httpd.serve_forever()
''')

print(f"✅ Created: serve_images.py")
print("-" * 80)

# Final Summary
print("\n" + "=" * 80)
print("🎉 SETUP COMPLETE!")
print("=" * 80)
print(f"📁 Images copied: {copied_count}")
print(f"✅ Products updated: {updated_count}")
print(f"📍 Images location: {IMAGES_DEST}")
print("=" * 80)

print("\n📱 TO TEST WITH YOUR FLUTTER APP:")
print("-" * 80)
print("1. Start the image server:")
print(f"   cd {WEBSITE_FOLDER}")
print("   python serve_images.py")
print()
print("2. Your Flutter app can now load images from:")
print(f"   {BASE_URL}/[category]/[filename]")
print()
print("3. Keep the server running while testing!")
print("=" * 80)

print("\n🌐 TO DEPLOY TO PRODUCTION:")
print("-" * 80)
print("Option A: Deploy website to Netlify/Vercel (FREE)")
print("   - Upload website folder to GitHub")
print("   - Connect to Netlify")
print("   - Update BASE_URL in this script")
print("   - Re-run to update Firestore URLs")
print()
print("Option B: Use any web hosting")
print("   - Upload product_images folder")
print("   - Update BASE_URL")
print("   - Re-run script")
print("=" * 80)

print(f"\n✅ Your products now have image URLs!")
print(f"⚠️  Start the server to test: python {server_script}")
print("=" * 80)
