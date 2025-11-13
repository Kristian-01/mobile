"""
🔄 UPDATE FIRESTORE WITH CLOUDINARY URLS (BATCHED)
====================================================

This script updates Firestore products with Cloudinary URLs in small batches
to avoid quota limits. It also auto-detects which products collection is used
('products' vs 'Products') and builds a Cloudinary index per category for
accurate product-to-image matching.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import re
import time
import cloudinary
import cloudinary.api

# Initialize Firebase
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# Your Cloudinary credentials
CLOUDINARY_CLOUD_NAME = "dskjwr7g4"
CLOUDINARY_API_KEY = "665786365357986"
CLOUDINARY_API_SECRET = "NMMdgKxtdqvgfRENMtmFgqB8BbM"

# Configure Cloudinary
cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True,
)

# Category mapping
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

def normalize_for_match(text: str) -> str:
    """Normalize a string for fuzzy matching (lowercase, remove punctuation, collapse spaces)."""
    text = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', text or '', flags=re.IGNORECASE)
    text = text.lower()
    text = re.sub(r'[^\w\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def build_cloudinary_index():
    """Build an index of Cloudinary assets per category for accurate matching.
    Returns: { folder: { normalized_name: secure_url } }
    """
    print("\n🗂️  Building Cloudinary index per category...")
    index = {folder: {} for folder in CATEGORY_TO_FOLDER.values()}
    for folder in CATEGORY_TO_FOLDER.values():
        prefix = f"product_images/{folder}"
        next_cursor = None
        fetched = 0
        while True:
            params = {"type": "upload", "prefix": prefix, "max_results": 500}
            if next_cursor:
                params["next_cursor"] = next_cursor
            res = cloudinary.api.resources(**params)
            resources = res.get("resources", [])
            for r in resources:
                public_id = r.get("public_id", "")  # e.g., product_images/personal_care/2in1_Lipstick_Romantic
                secure_url = r.get("secure_url", "")
                base = public_id.split("/")[-1]
                key = normalize_for_match(base)
                if key and secure_url:
                    index[folder][key] = secure_url
            fetched += len(resources)
            next_cursor = res.get("next_cursor")
            if not next_cursor:
                break
        print(f"  ✅ {folder:<20} indexed {fetched} images")
    return index

def find_best_match(product_name: str, folder_index: dict) -> str:
    """Find the best Cloudinary URL match for a product within a folder index.
    Returns secure_url or None.
    """
    if not folder_index:
        return None
    key = normalize_for_match(product_name)
    if not key:
        return None
    # Exact match
    if key in folder_index:
        return folder_index[key]
    # Fuzzy contains
    for k, url in folder_index.items():
        if (len(key) > 5 and (key in k or k in key)):
            return url
    return None

def get_products_collection():
    """Auto-detect whether 'products' or 'Products' collection has documents."""
    print("\n🔎 Detecting products collection...")
    for name in ["products", "Products"]:
        try:
            docs = db.collection(name).limit(1).get()
            if docs:
                print(f"✅ Using '{name}' collection")
                return db.collection(name)
        except Exception:
            pass
    print("⚠️  No documents found in 'products' or 'Products'. Defaulting to 'Products'.")
    return db.collection("Products")

def update_products_batch(batch_size=50):
    """Update products in small batches"""
    print("\n📊 Fetching products to update...")
    
    # Detect correct collection
    products_ref = get_products_collection()
    
    # Build Cloudinary index once
    cloud_index = build_cloudinary_index()
    
    # Start with first batch
    last_doc = None
    total_updated = 0
    total_skipped = 0
    total_processed = 0
    batch_num = 1
    
    while True:
        print(f"\n📦 Processing batch {batch_num}...")
        
        # Query batch
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(batch_size)
        else:
            query = products_ref.order_by('__name__').limit(batch_size)
        
        docs = query.get()
        
        if not docs:
            break  # No more products
        
        # Update this batch
        for doc in docs:
            total_processed += 1
            product = doc.to_dict()
            product_name = product.get('name', product.get('title', ''))
            category_id = product.get('categoryId', '').upper()
            
            if not product_name or not category_id:
                continue
            
            # Skip if already using Cloudinary URL
            thumb = (product.get('thumbnail') or '').lower()
            if 'cloudinary.com' in thumb:
                total_skipped += 1
                continue

            # Get folder name
            folder = CATEGORY_TO_FOLDER.get(category_id)
            if not folder:
                continue
            
            # Find the best Cloudinary URL match from index
            cloudinary_url = find_best_match(product_name, cloud_index.get(folder, {}))
            
            try:
                # Update product
                if cloudinary_url:
                    doc.reference.update({
                        'thumbnail': cloudinary_url,
                        'images': [cloudinary_url]
                    })
                else:
                    # Skip if no match found
                    continue
                
                total_updated += 1
                
                if total_updated % 10 == 0:
                    print(f"  ✅ Updated {total_updated} products (skipped {total_skipped})...")
                
            except Exception as e:
                print(f"  ⚠️  Failed: {product_name[:40]}")
        
        # Save last doc for pagination
        last_doc = docs[-1]
        batch_num += 1
        
        # Sleep a bit to avoid quota limits
        print(f"  💤 Sleeping 2 seconds to avoid quota limits...")
        time.sleep(2)
    
    return total_processed, total_updated

def main():
    """Main execution"""
    print("\n" + "=" * 80)
    print("🚀 UPDATING FIRESTORE WITH CLOUDINARY URLS")
    print("=" * 80)
    print(f"Cloud Name: {CLOUDINARY_CLOUD_NAME}")
    print("\n💡 This will update products in small batches to avoid quota limits")
    
    try:
        total_processed, total_updated = update_products_batch(batch_size=50)
        
        print("\n" + "=" * 80)
        print("✅ UPDATE COMPLETE!")
        print("=" * 80)
        print(f"Total processed: {total_processed}")
        print(f"Total updated: {total_updated}")
        # Note: skipped count is printed progressively during updates
        
        print("\n💡 Next steps:")
        print("  1. Test website - images should load from Cloudinary")
        print("  2. Test mobile - images should load from Cloudinary")
        print("  3. Check Cloudinary dashboard:")
        print(f"     https://cloudinary.com/console/c-{CLOUDINARY_CLOUD_NAME}/media_library")
        
    except Exception as e:
        if "429" in str(e) or "Quota" in str(e):
            print("\n⚠️  QUOTA LIMIT REACHED!")
            print("=" * 80)
            print("Your Firestore free tier quota is exceeded for today.")
            print("\n💡 Solutions:")
            print("  1. Wait a few hours and run again")
            print("  2. Quota resets daily (usually midnight Pacific Time)")
            print("  3. Or upgrade to Blaze plan (pay-as-you-go)")
            print(f"\nProgress saved: {total_updated if 'total_updated' in locals() else 0} products updated")
        else:
            print(f"\n💥 ERROR: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Update cancelled")
