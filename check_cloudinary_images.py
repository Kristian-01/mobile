"""
☁️ CHECK CLOUDINARY IMAGES
===========================

This script checks what images are currently in Cloudinary
and compares with local images.
"""

import firebase_admin
from firebase_admin import credentials, firestore
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

def extract_cloudinary_info(url):
    """Extract info from Cloudinary URL"""
    # Example: https://res.cloudinary.com/cloud-name/image/upload/folder/filename.jpg
    match = re.search(r'cloudinary\.com/([^/]+)/image/upload/(.+)$', url)
    if match:
        cloud_name = match.group(1)
        path = match.group(2)
        return {
            'cloud_name': cloud_name,
            'path': path,
            'is_cloudinary': True
        }
    return {'is_cloudinary': False}

def check_products():
    """Check all products and their image URLs"""
    products_ref = db.collection('products')
    all_products = products_ref.get()
    
    stats = {
        'total': 0,
        'cloudinary': 0,
        'firebase': 0,
        'localhost': 0,
        'other': 0,
        'no_url': 0
    }
    
    cloudinary_urls = []
    localhost_urls = []
    firebase_urls = []
    
    print("\n📊 Analyzing product image URLs...")
    print("=" * 80)
    
    for doc in all_products:
        stats['total'] += 1
        product = doc.to_dict()
        product_name = product.get('name', product.get('title', 'Unknown'))
        thumbnail = product.get('thumbnail', '')
        
        if not thumbnail:
            stats['no_url'] += 1
            print(f"  ⚠️  No URL: {product_name}")
            continue
        
        if 'cloudinary' in thumbnail.lower():
            stats['cloudinary'] += 1
            cloudinary_urls.append({
                'name': product_name,
                'url': thumbnail,
                'info': extract_cloudinary_info(thumbnail)
            })
        elif 'firebasestorage' in thumbnail.lower():
            stats['firebase'] += 1
            firebase_urls.append({
                'name': product_name,
                'url': thumbnail
            })
        elif 'localhost' in thumbnail.lower():
            stats['localhost'] += 1
            localhost_urls.append({
                'name': product_name,
                'url': thumbnail
            })
        else:
            stats['other'] += 1
            print(f"  ❓ Other URL type: {product_name} - {thumbnail[:50]}...")
    
    # Display summary
    print("\n" + "=" * 80)
    print("📊 URL SUMMARY")
    print("=" * 80)
    print(f"Total products: {stats['total']}")
    print(f"  ☁️  Cloudinary: {stats['cloudinary']}")
    print(f"  🔥 Firebase: {stats['firebase']}")
    print(f"  🏠 Localhost: {stats['localhost']}")
    print(f"  ❓ Other: {stats['other']}")
    print(f"  ⚠️  No URL: {stats['no_url']}")
    
    # Show Cloudinary details
    if cloudinary_urls:
        print("\n" + "=" * 80)
        print("☁️  CLOUDINARY IMAGES")
        print("=" * 80)
        
        # Group by cloud name
        cloud_names = {}
        for item in cloudinary_urls:
            if item['info']['is_cloudinary']:
                cloud = item['info']['cloud_name']
                if cloud not in cloud_names:
                    cloud_names[cloud] = []
                cloud_names[cloud].append(item)
        
        for cloud, items in cloud_names.items():
            print(f"\n📦 Cloud: {cloud} ({len(items)} images)")
            print("-" * 80)
            for item in items[:10]:  # Show first 10
                print(f"  - {item['name']}")
                print(f"    Path: {item['info']['path']}")
            if len(items) > 10:
                print(f"  ... and {len(items) - 10} more")
    
    # Show localhost URLs
    if localhost_urls:
        print("\n" + "=" * 80)
        print("🏠 LOCALHOST URLS (BROKEN)")
        print("=" * 80)
        print(f"Found {len(localhost_urls)} products with localhost URLs")
        print("These need to be migrated to Firebase Storage!")
        for item in localhost_urls[:5]:
            print(f"  - {item['name']}")
        if len(localhost_urls) > 5:
            print(f"  ... and {len(localhost_urls) - 5} more")
    
    # Show Firebase URLs
    if firebase_urls:
        print("\n" + "=" * 80)
        print("🔥 FIREBASE STORAGE URLS (GOOD!)")
        print("=" * 80)
        print(f"Found {len(firebase_urls)} products already using Firebase")
        for item in firebase_urls[:5]:
            print(f"  - {item['name']}")
        if len(firebase_urls) > 5:
            print(f"  ... and {len(firebase_urls) - 5} more")
    
    # Recommendation
    print("\n" + "=" * 80)
    print("💡 RECOMMENDATION")
    print("=" * 80)
    
    if stats['cloudinary'] > 0:
        print(f"☁️  You have {stats['cloudinary']} products using Cloudinary")
        print("   These can stay OR be migrated to Firebase Storage")
        print("   Cloudinary is fine to use!")
    
    if stats['localhost'] > 0:
        print(f"🏠 You have {stats['localhost']} products using localhost URLs")
        print("   ⚠️  These are BROKEN and need to be fixed!")
        print("   Run: python migrate_to_firebase_storage.py")
    
    if stats['no_url'] > 0:
        print(f"❌ You have {stats['no_url']} products without images")
        print("   These will be deleted during migration")
    
    print("\n" + "=" * 80)

if __name__ == "__main__":
    try:
        check_products()
    except Exception as e:
        print(f"\n💥 ERROR: {e}")
        import traceback
        traceback.print_exc()
