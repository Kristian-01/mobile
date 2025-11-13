import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
try:
    firebase_admin.get_app()
except:
    firebase_admin.initialize_app(cred)
db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# Check products
print("\n📦 CHECKING PRODUCT PRICES:")
print("-" * 80)

products_ref = db.collection('Products').get()
total_products = len(products_ref)

# Analyze prices
products_with_price = 0
products_without_price = 0
products_with_zero_price = 0
price_list = []

no_price_samples = []
zero_price_samples = []

for product in products_ref:
    product_data = product.to_dict()
    product_name = product_data.get('title', 'Unknown')
    price = product_data.get('price')
    
    if price is None or price == '':
        products_without_price += 1
        if len(no_price_samples) < 5:
            no_price_samples.append(product_name)
    elif price == 0 or price == 0.0:
        products_with_zero_price += 1
        if len(zero_price_samples) < 5:
            zero_price_samples.append(product_name)
    else:
        products_with_price += 1
        price_list.append(float(price))

print(f"Total Products: {total_products}")
print()
print(f"✅ Products WITH valid price  : {products_with_price:4d} ({products_with_price/total_products*100:.1f}%)")
print(f"⚠️  Products with ZERO price   : {products_with_zero_price:4d} ({products_with_zero_price/total_products*100:.1f}%)")
print(f"❌ Products WITHOUT price field: {products_without_price:4d} ({products_without_price/total_products*100:.1f}%)")

if products_with_price > 0:
    print()
    print("💰 Price Statistics:")
    print("-" * 80)
    print(f"  Lowest Price : ₱{min(price_list):,.2f}")
    print(f"  Highest Price: ₱{max(price_list):,.2f}")
    print(f"  Average Price: ₱{sum(price_list)/len(price_list):,.2f}")

if zero_price_samples:
    print()
    print("⚠️  Sample products with ZERO price:")
    print("-" * 80)
    for i, name in enumerate(zero_price_samples, 1):
        print(f"  {i}. {name}")

if no_price_samples:
    print()
    print("❌ Sample products WITHOUT price:")
    print("-" * 80)
    for i, name in enumerate(no_price_samples, 1):
        print(f"  {i}. {name}")

print()
print("=" * 80)
if products_with_price == total_products:
    print("✅ ALL PRODUCTS HAVE VALID PRICES!")
elif products_with_zero_price > 0 or products_without_price > 0:
    print("⚠️  SOME PRODUCTS NEED PRICE UPDATES")
    print(f"   {products_with_zero_price + products_without_price} products need pricing")
print("=" * 80)
