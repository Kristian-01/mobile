import firebase_admin
from firebase_admin import credentials, storage
from collections import defaultdict

# Init Firebase (use service account)
try:
    firebase_admin.get_app()
except:
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'mobile-e4ddd.appspot.com'
    })

bucket = storage.bucket()

print("🔥 Connected to Firebase Storage bucket:", bucket.name)

# Count images under product_images/<category>/
folder_counts = defaultdict(int)
product_total = 0

# Also track overall bucket image count
bucket_total = 0

def is_image(name: str) -> bool:
    n = name.lower()
    return n.endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'))

# Count product_images/*
for blob in bucket.list_blobs(prefix='product_images/'):
    if blob.name.endswith('/'):
        continue
    if is_image(blob.name):
        bucket_total += 1
        product_total += 1
        parts = blob.name.split('/')  # product_images/<folder>/<file>
        if len(parts) >= 3:
            folder = parts[1]
            folder_counts[folder] += 1

# Count other images outside product_images (optional)
other_total = 0
for blob in bucket.list_blobs():
    if blob.name.endswith('/'):
        continue
    if is_image(blob.name):
        # Exclude ones we already counted under product_images
        if not blob.name.startswith('product_images/'):
            bucket_total += 1
            other_total += 1

print("\n================ FIREBASE STORAGE IMAGE COUNTS ================")
print(f"Bucket: {bucket.name}")
print("\nProduct images (product_images/*):")
for folder in sorted(folder_counts.keys()):
    print(f"  - {folder:18} : {folder_counts[folder]} images")
print(f"\nTotal product images   : {product_total}")
print(f"Other images (outside): {other_total}")
print(f"\nTOTAL images in bucket : {bucket_total}")
