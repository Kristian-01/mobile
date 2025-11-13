import csv
import os
import firebase_admin
from firebase_admin import credentials, firestore
from pathlib import Path
import re

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
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

def normalize_name(name):
    """Normalize product name for comparison"""
    # Remove file extensions
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    # Convert to lowercase
    name = name.lower()
    # Remove special characters and extra spaces
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def get_all_images():
    """Get all image files from all folders"""
    all_images = {}
    
    for category, folder in image_folders.items():
        images = []
        if os.path.exists(folder):
            for file in os.listdir(folder):
                if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                    images.append(file)
        all_images[category] = images
        print(f"📁 {category}: {len(images)} images found")
    
    return all_images

def get_products_from_csv(category):
    """Get all products from a CSV file"""
    csv_file = csv_files.get(category)
    if not csv_file or not os.path.exists(csv_file):
        return []
    
    products = []
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            products.append(row['Product Name'].strip())
    
    return products

def check_product_has_image(product_name, images):
    """Check if a product has a corresponding image"""
    normalized_product = normalize_name(product_name)
    
    for image in images:
        normalized_image = normalize_name(image)
        
        # Check if product name matches image name
        if normalized_product == normalized_image:
            return True
        
        # Check if product name is contained in image name
        if normalized_product in normalized_image or normalized_image in normalized_product:
            # More strict matching for short names
            if len(normalized_product) > 5:
                return True
    
    return False

def remove_products_from_csv(category, products_to_remove):
    """Remove products from CSV file"""
    csv_file = csv_files.get(category)
    if not csv_file or not os.path.exists(csv_file):
        return 0
    
    # Read all products
    remaining_products = []
    removed_count = 0
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        
        for row in reader:
            product_name = row['Product Name'].strip()
            if product_name not in products_to_remove:
                remaining_products.append(row)
            else:
                removed_count += 1
    
    # Write back remaining products
    with open(csv_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(remaining_products)
    
    return removed_count

def remove_products_from_firestore(products_to_remove):
    """Remove products from Firestore"""
    removed_count = 0
    
    for product_name in products_to_remove:
        # Query for products with this name
        products_ref = db.collection('products')
        query = products_ref.where('name', '==', product_name)
        docs = query.get()
        
        for doc in docs:
            doc.reference.delete()
            removed_count += 1
    
    return removed_count

# Main execution
print("\n📊 Analyzing products and images...")
print("=" * 80)

all_images = get_all_images()
products_without_images = {}
total_products = 0
total_without_images = 0

# Check each category
for category in csv_files.keys():
    print(f"\n🔍 Checking {category}...")
    print("-" * 80)
    
    products = get_products_from_csv(category)
    images = all_images.get(category, [])
    
    products_missing_images = []
    
    for product in products:
        total_products += 1
        if not check_product_has_image(product, images):
            products_missing_images.append(product)
            print(f"  ❌ NO IMAGE: {product}")
    
    if products_missing_images:
        products_without_images[category] = products_missing_images
        total_without_images += len(products_missing_images)
        print(f"\n  ⚠️  Found {len(products_missing_images)} products without images in {category}")
    else:
        print(f"  ✅ All products in {category} have images!")

# Summary
print("\n" + "=" * 80)
print("📊 SUMMARY")
print("=" * 80)
print(f"Total products checked: {total_products}")
print(f"Products without images: {total_without_images}")

if total_without_images > 0:
    print("\n" + "=" * 80)
    print("🗑️  PRODUCTS TO REMOVE:")
    print("=" * 80)
    
    for category, products in products_without_images.items():
        print(f"\n{category}:")
        for product in products:
            print(f"  - {product}")
    
    # Ask for confirmation
    print("\n" + "=" * 80)
    response = input("\n⚠️  Do you want to remove these products from CSV and Firestore? (yes/no): ")
    
    if response.lower() in ['yes', 'y']:
        print("\n🗑️  Removing products...")
        print("=" * 80)
        
        total_removed_csv = 0
        all_products_to_remove = []
        
        # Remove from CSV
        for category, products in products_without_images.items():
            removed = remove_products_from_csv(category, products)
            total_removed_csv += removed
            all_products_to_remove.extend(products)
            print(f"✅ Removed {removed} products from {category} CSV")
        
        # Remove from Firestore
        print("\n🔥 Removing from Firestore...")
        total_removed_firestore = remove_products_from_firestore(all_products_to_remove)
        
        print("\n" + "=" * 80)
        print("✅ CLEANUP COMPLETE!")
        print("=" * 80)
        print(f"Removed from CSV: {total_removed_csv} products")
        print(f"Removed from Firestore: {total_removed_firestore} documents")
    else:
        print("\n❌ Operation cancelled.")
else:
    print("\n✅ All products have corresponding images!")

print("\n" + "=" * 80)
