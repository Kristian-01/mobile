"""
📝 REPORT UNMATCHED PRODUCTS (NO CLOUDINARY IMAGE)
===================================================

Find products that still don't have Cloudinary image URLs.
Optionally delete them from Firestore (with confirmation).
"""

import re
import time
import firebase_admin
from firebase_admin import credentials, firestore
import cloudinary
import cloudinary.api

# ---- Cloudinary config ----
CLOUDINARY_CLOUD_NAME = "dskjwr7g4"
CLOUDINARY_API_KEY = "665786365357986"
CLOUDINARY_API_SECRET = "NMMdgKxtdqvgfRENMtmFgqB8BbM"

cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True,
)

# ---- Firebase init ----
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

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
    text = re.sub(r'\.(jpg|png|webp|gif|jpeg)$', '', text or '', flags=re.IGNORECASE)
    text = text.lower()
    text = re.sub(r'[^\w\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def build_cloudinary_index():
    print("\n🗂️  Building Cloudinary index per category (for matching)...")
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
                public_id = r.get("public_id", "")
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

def get_products_collection():
    for name in ["products", "Products"]:
        docs = db.collection(name).limit(1).get()
        if docs:
            return db.collection(name)
    return db.collection("Products")

def find_best_match(product_name: str, folder_index: dict) -> str:
    if not folder_index:
        return None
    key = normalize_for_match(product_name)
    if not key:
        return None
    if key in folder_index:
        return folder_index[key]
    for k, url in folder_index.items():
        if len(key) > 5 and (key in k or k in key):
            return url
    return None

def main():
    print("\n🔥 Connected. Starting unmatched report...")

    cloud_index = build_cloudinary_index()
    products_ref = get_products_collection()

    print("\n📦 Scanning products...")

    last_doc = None
    batch_size = 200

    no_cloudinary = []
    has_cloudinary = 0
    total = 0

    while True:
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(batch_size)
        else:
            query = products_ref.order_by('__name__').limit(batch_size)
        docs = query.get()
        if not docs:
            break

        for doc in docs:
            total += 1
            data = doc.to_dict()
            name = data.get('name', data.get('title', ''))
            cat = (data.get('categoryId') or '').upper()
            thumb = (data.get('thumbnail') or '').lower()

            if 'cloudinary.com' in thumb:
                has_cloudinary += 1
                continue

            folder = CATEGORY_TO_FOLDER.get(cat)
            url = find_best_match(name, cloud_index.get(folder, {})) if folder else None

            if not url:
                no_cloudinary.append({
                    'id': doc.id,
                    'name': name,
                    'category': cat
                })

        last_doc = docs[-1]

    print("\n================ RESULTS ================")
    print(f"Total products scanned : {total}")
    print(f"With Cloudinary URL    : {has_cloudinary}")
    print(f"WITHOUT Cloudinary URL : {len(no_cloudinary)}")

    if no_cloudinary:
        print("\nFirst 20 without Cloudinary:")
        for item in no_cloudinary[:20]:
            print(f"  - {item['name']} ({item['category']})")

        resp = input("\n⚠️  Delete ALL products without Cloudinary image from Firestore? (yes/no): ")
        if resp.lower() in ["y", "yes"]:
            deleted = 0
            for item in no_cloudinary:
                try:
                    db.collection(products_ref.id).document(item['id']).delete()
                    deleted += 1
                except Exception:
                    pass
            print(f"\n✅ Deleted {deleted} products without Cloudinary images.")
        else:
            print("\n❌ Deletion cancelled.")
    else:
        print("\n✅ All products have Cloudinary URLs. Great!")

if __name__ == "__main__":
    main()
