import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Get all products
products_ref = db.collection('Products')
all_products = products_ref.stream()

# Count by category
category_counts = {}
total = 0

for product in all_products:
    data = product.to_dict()
    category_id = data.get('categoryId', 'Unknown').lower()
    
    # Apply the same filter as the app
    is_pharmacy = False
    if category_id:
        if any(x in category_id for x in ['food', 'beverage', 'snack', 'household', 'others', 'other']):
            is_pharmacy = False
        elif any(x in category_id for x in [
            'multivitamins', 'vitamins', 'medicines', 'medicine',
            'topical_oral', 'topical oral', 'topical', 'oral',
            'cough_cold', 'cough cold', 'cough', 'cold',
            'medical_supplies', 'medical supplies',
            'personal_care', 'personal care',
            'baby_products', 'baby products',
            'female_care', 'female care',
            'feminine_care', 'feminine care'
        ]):
            is_pharmacy = True
    
    if is_pharmacy:
        total += 1
        category_counts[category_id] = category_counts.get(category_id, 0) + 1

print("\n" + "="*60)
print("NINE27 PHARMACY - FIREBASE PRODUCT COUNT")
print("="*60)
print(f"\n✅ TOTAL PHARMACY PRODUCTS: {total}\n")
print("Breakdown by Category:")
print("-" * 60)

for category, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
    print(f"  {category:30} : {count:4} products")

print("="*60)
