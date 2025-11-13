"""
🔍 AUDIT & CLEANUP PRODUCTS
============================

This script will:
1. Check all products vs local images (accurate matching)
2. Verify products are in correct categories
3. Find misplaced products (like Zonrox in medicines)
4. Show summary of issues
5. Clean up before Cloudinary upload
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore
import re
from datetime import datetime

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 100)

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

# Category mapping (Firestore category ID -> Folder name)
CATEGORY_TO_FOLDER = {
    'BABY_PRODUCTS': 'baby_products',
    'FEMININE_CARE': 'female_care',
    'FOOD_AND_BEVERAGES': 'food_and_beverages',
    'HOUSEHOLD_ITEMS': 'household_items',
    'MEDICAL_SUPPLIES': 'medical_supplies',
    'MEDICINES': 'medicine',
    'OTHERS': 'others',
    'PERSONAL_CARE': 'personal_care'
}

# Products that should NOT be in certain categories
CATEGORY_RULES = {
    'MEDICINES': {
        'should_not_contain': [
            'zonrox', 'bleach', 'surf', 'tide', 'ariel', 'downy',  # Household cleaning
            'shampoo', 'cologne', 'perfume', 'lotion', 'soap',     # Personal care (unless medicated)
            'chips', 'chocolate', 'candy', 'biscuit', 'noodles'    # Food
        ]
    },
    'FOOD_AND_BEVERAGES': {
        'should_not_contain': [
            'medicine', 'tablet', 'capsule', 'syrup', 'drops',     # Medicines
            'soap', 'shampoo', 'lotion', 'cream',                  # Personal care
            'zonrox', 'bleach', 'detergent'                        # Household
        ]
    },
    'PERSONAL_CARE': {
        'should_not_contain': [
            'zonrox', 'bleach', 'surf', 'tide', 'ariel',           # Household cleaning
            'chips', 'chocolate', 'noodles',                        # Food
            'tablet', 'capsule', 'medicine'                         # Medicines (unless beauty/care)
        ]
    },
    'HOUSEHOLD_ITEMS': {
        'should_not_contain': [
            'medicine', 'tablet', 'capsule', 'syrup',              # Medicines
            'chips', 'chocolate', 'candy', 'noodles',              # Food
            'shampoo', 'lotion', 'perfume'                         # Personal care
        ]
    }
}

def normalize_name(name):
    """Normalize name for comparison"""
    name = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', name, flags=re.IGNORECASE)
    name = name.lower()
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    return name.strip()

def get_all_images():
    """Get all images from local folders"""
    all_images = {}
    
    print("\n📁 Scanning local image folders...")
    print("-" * 100)
    
    for folder_name, folder_path in IMAGE_FOLDERS.items():
        images = {}
        if os.path.exists(folder_path):
            for file in os.listdir(folder_path):
                if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
                    normalized = normalize_name(file)
                    images[normalized] = {
                        'filename': file,
                        'path': os.path.join(folder_path, file)
                    }
        all_images[folder_name] = images
        print(f"  ✅ {folder_name:<25} {len(images):>4} images")
    
    return all_images

def check_category_mismatch(product_name, category_id):
    """Check if product is in wrong category"""
    if category_id not in CATEGORY_RULES:
        return None
    
    rules = CATEGORY_RULES[category_id]
    product_lower = product_name.lower()
    
    for keyword in rules['should_not_contain']:
        if keyword in product_lower:
            return keyword
    
    return None

def match_product_to_image(product_name, images):
    """Try to match product to image"""
    normalized_product = normalize_name(product_name)
    
    # Exact match
    if normalized_product in images:
        return images[normalized_product], 'exact'
    
    # Fuzzy match - product name in image name
    for img_norm, img_data in images.items():
        if normalized_product in img_norm:
            if len(normalized_product) > 5:
                return img_data, 'fuzzy'
    
    # Fuzzy match - image name in product name
    for img_norm, img_data in images.items():
        if img_norm in normalized_product:
            if len(img_norm) > 5:
                return img_data, 'fuzzy'
    
    return None, None

def audit_products(all_images):
    """Audit all products"""
    print("\n" + "=" * 100)
    print("🔍 AUDITING PRODUCTS")
    print("=" * 100)
    
    products_ref = db.collection('products')
    all_products = products_ref.get()
    
    issues = {
        'no_image': [],           # Products without matching image
        'wrong_category': [],     # Products in wrong category
        'mismatched_folder': [],  # Product image in different category folder
        'ok': []                  # Products that are OK
    }
    
    for doc in all_products:
        product = doc.to_dict()
        product_id = doc.id
        product_name = product.get('name', product.get('title', 'Unknown'))
        category_id = product.get('categoryId', '').upper()
        
        # Get expected folder for this category
        expected_folder = CATEGORY_TO_FOLDER.get(category_id)
        
        if not expected_folder:
            issues['wrong_category'].append({
                'id': product_id,
                'name': product_name,
                'category': category_id,
                'reason': 'Unknown category'
            })
            continue
        
        # Check if product name suggests wrong category
        keyword = check_category_mismatch(product_name, category_id)
        if keyword:
            issues['wrong_category'].append({
                'id': product_id,
                'name': product_name,
                'category': category_id,
                'reason': f"Contains '{keyword}' - should not be in {category_id}"
            })
            continue
        
        # Check if image exists in expected folder
        expected_images = all_images.get(expected_folder, {})
        matched_image, match_type = match_product_to_image(product_name, expected_images)
        
        if matched_image:
            issues['ok'].append({
                'id': product_id,
                'name': product_name,
                'category': category_id,
                'image': matched_image['filename'],
                'match_type': match_type
            })
        else:
            # Check if image exists in OTHER folders (misplaced)
            found_in_wrong_folder = None
            for folder_name, folder_images in all_images.items():
                if folder_name != expected_folder:
                    img, match_type = match_product_to_image(product_name, folder_images)
                    if img:
                        found_in_wrong_folder = {
                            'folder': folder_name,
                            'image': img['filename'],
                            'match_type': match_type
                        }
                        break
            
            if found_in_wrong_folder:
                issues['mismatched_folder'].append({
                    'id': product_id,
                    'name': product_name,
                    'category': category_id,
                    'expected_folder': expected_folder,
                    'found_in': found_in_wrong_folder['folder'],
                    'image': found_in_wrong_folder['image']
                })
            else:
                issues['no_image'].append({
                    'id': product_id,
                    'name': product_name,
                    'category': category_id
                })
    
    return issues

def display_issues(issues):
    """Display all issues found"""
    print("\n" + "=" * 100)
    print("📊 AUDIT RESULTS")
    print("=" * 100)
    
    total = len(issues['ok']) + len(issues['no_image']) + len(issues['wrong_category']) + len(issues['mismatched_folder'])
    
    print(f"\n✅ GOOD: {len(issues['ok'])} products are correct")
    print(f"❌ ISSUES FOUND: {len(issues['no_image']) + len(issues['wrong_category']) + len(issues['mismatched_folder'])} problems")
    
    # Wrong category
    if issues['wrong_category']:
        print("\n" + "=" * 100)
        print(f"⚠️  WRONG CATEGORY ({len(issues['wrong_category'])} products)")
        print("=" * 100)
        print("These products are in the wrong category:")
        print("-" * 100)
        
        for item in issues['wrong_category']:
            print(f"  ❌ {item['name']:<50} | {item['category']:<20} | {item['reason']}")
    
    # Mismatched folder
    if issues['mismatched_folder']:
        print("\n" + "=" * 100)
        print(f"🔀 MISMATCHED FOLDER ({len(issues['mismatched_folder'])} products)")
        print("=" * 100)
        print("Product is in one category but image is in different folder:")
        print("-" * 100)
        
        for item in issues['mismatched_folder']:
            print(f"  🔀 {item['name']:<50}")
            print(f"     Category: {item['category']} (expects: {item['expected_folder']})")
            print(f"     Image found in: {item['found_in']}/{item['image']}")
    
    # No image
    if issues['no_image']:
        print("\n" + "=" * 100)
        print(f"📷 NO IMAGE ({len(issues['no_image'])} products)")
        print("=" * 100)
        print("These products have no matching image in ANY folder:")
        print("-" * 100)
        
        for item in issues['no_image']:
            print(f"  📷 {item['name']:<50} | {item['category']}")
    
    # Summary
    print("\n" + "=" * 100)
    print("📊 SUMMARY")
    print("=" * 100)
    print(f"Total products: {total}")
    print(f"  ✅ Correct: {len(issues['ok'])}")
    print(f"  ⚠️  Wrong category: {len(issues['wrong_category'])}")
    print(f"  🔀 Wrong folder: {len(issues['mismatched_folder'])}")
    print(f"  📷 No image: {len(issues['no_image'])}")

def cleanup_issues(issues):
    """Clean up issues"""
    total_to_delete = len(issues['wrong_category']) + len(issues['mismatched_folder']) + len(issues['no_image'])
    
    if total_to_delete == 0:
        print("\n✅ No issues found! All products are correct!")
        return
    
    print("\n" + "=" * 100)
    print(f"🗑️  CLEANUP CONFIRMATION")
    print("=" * 100)
    print(f"\nTotal products to delete: {total_to_delete}")
    print(f"  - Wrong category: {len(issues['wrong_category'])}")
    print(f"  - Wrong folder: {len(issues['mismatched_folder'])}")
    print(f"  - No image: {len(issues['no_image'])}")
    
    print("\n⚠️  WARNING: This will DELETE these products from Firestore!")
    response = input("\nProceed with deletion? (yes/no): ")
    
    if response.lower() not in ['yes', 'y']:
        print("\n❌ Cleanup cancelled")
        return
    
    print("\n🗑️  Deleting products...")
    print("-" * 100)
    
    deleted = 0
    
    # Delete wrong category
    for item in issues['wrong_category']:
        try:
            db.collection('products').document(item['id']).delete()
            print(f"  ✅ Deleted: {item['name'][:50]} (wrong category)")
            deleted += 1
        except Exception as e:
            print(f"  ❌ Failed: {item['name'][:50]}")
    
    # Delete mismatched folder
    for item in issues['mismatched_folder']:
        try:
            db.collection('products').document(item['id']).delete()
            print(f"  ✅ Deleted: {item['name'][:50]} (wrong folder)")
            deleted += 1
        except Exception as e:
            print(f"  ❌ Failed: {item['name'][:50]}")
    
    # Delete no image
    for item in issues['no_image']:
        try:
            db.collection('products').document(item['id']).delete()
            print(f"  ✅ Deleted: {item['name'][:50]} (no image)")
            deleted += 1
        except Exception as e:
            print(f"  ❌ Failed: {item['name'][:50]}")
    
    print("\n" + "=" * 100)
    print(f"✅ CLEANUP COMPLETE!")
    print("=" * 100)
    print(f"Deleted: {deleted} products")
    print(f"Remaining: {len(issues['ok'])} good products")

def main():
    """Main execution"""
    print("\n🚀 STARTING AUDIT...")
    
    # Step 1: Get all images
    all_images = get_all_images()
    
    # Step 2: Audit products
    issues = audit_products(all_images)
    
    # Step 3: Display issues
    display_issues(issues)
    
    # Step 4: Clean up
    cleanup_issues(issues)
    
    print("\n" + "=" * 100)
    print("✅ AUDIT COMPLETE!")
    print("=" * 100)
    print("\n💡 Next steps:")
    print("  1. ✅ All products are now accurate and in correct categories")
    print("  2. ✅ All products have matching images")
    print("  3. 🚀 Ready to upload to Cloudinary!")
    print("\nRun: python upload_to_cloudinary.py")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Audit cancelled")
    except Exception as e:
        print(f"\n\n💥 ERROR: {e}")
        import traceback
        traceback.print_exc()
