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

# Step 1: Check current products
print("\n📊 Checking current products in Firestore...")
print("-" * 80)

products_ref = db.collection('Products')

# Count products with placeholders vs real images
placeholder_count = 0
real_image_count = 0
total_count = 0

try:
    # Get all products in small batches
    last_doc = None
    
    while True:
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(50)
        else:
            query = products_ref.order_by('__name__').limit(50)
        
        docs = list(query.stream())
        
        if not docs:
            break
        
        for doc in docs:
            total_count += 1
            data = doc.to_dict()
            thumbnail = data.get('thumbnail', '')
            
            if 'placeholder' in thumbnail.lower() or 'via.placeholder' in thumbnail.lower():
                placeholder_count += 1
            else:
                real_image_count += 1
        
        last_doc = docs[-1]
        
        print(f"  Checked {total_count} products...")
        time.sleep(0.5)
        
except Exception as e:
    print(f"❌ Error: {e}")

print(f"\n📊 Results:")
print(f"  Total products: {total_count}")
print(f"  With placeholders: {placeholder_count}")
print(f"  With real images: {real_image_count}")
print("-" * 80)

# Step 2: Delete ALL products with placeholders
if placeholder_count > 0:
    print(f"\n🗑️  Deleting {placeholder_count} products with placeholder images...")
    print("-" * 80)
    
    deleted_count = 0
    
    try:
        # Delete in very small batches to avoid quota
        while True:
            # Find products with placeholders
            query = products_ref.limit(10)
            docs = list(query.stream())
            
            if not docs:
                break
            
            batch = db.batch()
            batch_ops = 0
            
            for doc in docs:
                data = doc.to_dict()
                thumbnail = data.get('thumbnail', '')
                
                if 'placeholder' in thumbnail.lower() or 'via.placeholder' in thumbnail.lower():
                    batch.delete(doc.reference)
                    deleted_count += 1
                    batch_ops += 1
            
            if batch_ops > 0:
                batch.commit()
                print(f"  🗑️  Deleted {deleted_count} products...")
                time.sleep(2)  # Wait to avoid quota
            else:
                # No more placeholders found
                break
                
    except Exception as e:
        print(f"❌ Error deleting: {e}")
    
    print(f"✅ Deleted {deleted_count} products with placeholders")
else:
    print("\n✅ No products with placeholders found!")

# Step 3: Final count
print("\n📊 Final count...")
print("-" * 80)

try:
    final_count = 0
    last_doc = None
    
    while True:
        if last_doc:
            query = products_ref.order_by('__name__').start_after(last_doc).limit(100)
        else:
            query = products_ref.order_by('__name__').limit(100)
        
        docs = list(query.stream())
        
        if not docs:
            break
        
        final_count += len(docs)
        last_doc = docs[-1]
        time.sleep(0.5)
        
    print(f"✅ Final product count: {final_count}")
    
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "=" * 80)
print("🎉 CLEANUP COMPLETE!")
print("=" * 80)
print(f"🗑️  Removed products with placeholders: {deleted_count if placeholder_count > 0 else 0}")
print(f"📦 Remaining products: {final_count}")
print("=" * 80)
print(f"\n🔗 View: https://console.firebase.google.com/project/mobile-e4ddd/firestore")
print("=" * 80)

if final_count == 0:
    print("\n⚠️  WARNING: All products deleted!")
    print("   You need to re-upload products with REAL images.")
elif real_image_count > 0:
    print(f"\n✅ Your Flutter app now shows {final_count} products with real images!")
else:
    print("\n⚠️  No products with real images found.")
    print("   All remaining products may still have placeholders.")

print("=" * 80)
