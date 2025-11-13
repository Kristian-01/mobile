import csv
import re
from collections import defaultdict

# Read the CSV file
products = []
seen = set()

with open('product-list-2025.csv', 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    for row in reader:
        if len(row) >= 3 and row[0].strip():
            # Clean product name
            product_name = row[0].strip()
            
            # Skip header lines and non-product lines
            if product_name in ['NINE27 DRUGSTORE', 'Company Report', 'Inventory', 'Staff: NINETWENTYSEVEN', 'Total', ''] or 'NINE' in product_name.upper():
                continue
            
            # Skip if already seen (remove duplicates)
            if product_name not in seen:
                seen.add(product_name)
                try:
                    stock = int(row[2]) if row[2].strip() else 0
                except:
                    stock = 0
                products.append({'name': product_name, 'stock': stock})

# Categorization function
def categorize_product(name):
    name_upper = name.upper()
    
    # MEDICINES - Pills, Tablets, Capsules, Syrups, Drops, etc.
    medicine_keywords = [
        'TABLET', 'TAB', 'CAPSULE', 'CAP', 'SYRUP', 'SUSPENSION', 'DROPS', 
        'MG', 'MCG', 'ML', 'NEBULE', 'INHALER', 'OINTMENT', 'CREAM',
        'PARACETAMOL', 'BIOGESIC', 'IBUPROFEN', 'AMOXICILLIN', 'CETIRIZINE',
        'METFORMIN', 'AMLODIPINE', 'LOSARTAN', 'VITAMIN', 'MULTIVITAMIN',
        'ASCORBIC', 'NEOZEP', 'BIOFLU', 'SOLMUX', 'TEMPRA', 'ALAXAN',
        'MEFENAMIC', 'ANTIBIOTIC', 'COUGH', 'LAGUNDI', 'ASCOF',
        'ORAL DROPS', 'GRANULES', 'FORTE', 'PLUS', 'PILLS', 'ADVIL'
    ]
    
    # MEDICAL SUPPLIES
    medical_supply_keywords = [
        'SYRINGE', 'GAUZE', 'BANDAGE', 'STRIP', 'MASK', 'CANNULA',
        'THERMOMETER', 'GLOVES', 'DROPPER', 'NEBULIZER', 'BLOOD PRESSURE',
        'PREGNANCY TEST', 'ALCOHOL', 'HYDROGEN PEROXIDE', 'BETADINE',
        'COTTON', 'MEDIPLAST', 'OXYGEN', 'FACEMASK', 'SURGICAL'
    ]
    
    # BABY PRODUCTS
    baby_keywords = [
        'BABY', 'DIAPER', 'PAMPERS', 'LACTUM', 'BONAKID', 'BONNA', 'NESTOGEN',
        'NIDO', 'BIRCH TREE', 'BEAR BRAND', 'ANMUM', 'CERELAC', 'GERBER',
        'NIPPLE', 'FEEDING', 'JOHNSON', 'LAMPEIN', 'HAPPY PANTS', 'EQ',
        'CHERIFER', 'TIKI-TIKI', 'CEELIN', 'ERCEFLORA', 'NUTRILLIN'
    ]
    
    # PERSONAL CARE
    personal_care_keywords = [
        'SOAP', 'SHAMPOO', 'CONDITIONER', 'LOTION', 'DEODORANT', 'COLOGNE',
        'PERFUME', 'TOOTHPASTE', 'TOOTHBRUSH', 'FACIAL', 'CLEANSER',
        'WHITENING', 'SUNBLOCK', 'ASTRINGENT', 'TONER', 'MOISTURIZER',
        'SAFEGUARD', 'DOVE', 'PALMOLIVE', 'COLGATE', 'SILKA', 'KOJIE',
        'BENCH', 'AXE', 'REXONA', 'MASTERS', 'MAXI PEEL', 'ESKINOL',
        'PONDS', 'HAIR', 'NAIL', 'LIPSTICK', 'MAKEUP', 'COSMETIC',
        'TENDER CARE', 'PETROLEUM JELLY', 'POWDER'
    ]
    
    # FEMININE CARE
    feminine_keywords = [
        'MODESS', 'NAPKIN', 'PAD', 'PANTYLINER', 'FEMININE WASH',
        'SANITARY', 'WHISPER', 'SISTERS', 'CAREFREE', 'CHARMEE',
        'THOSE DAYS', 'SOFY', 'LADY PILLS', 'BIRTH CONTROL', 'GYNEPRO'
    ]
    
    # FOOD & BEVERAGES - Instant noodles, snacks, drinks, milk, coffee
    food_keywords = [
        'LUCKY ME', 'NISSIN', 'PANCIT', 'NOODLES', 'YAKISOBA',
        'CHIPS', 'BISCUIT', 'CRACKER', 'CANDY', 'CHOCOLATE', 'CHOCO',
        'COOKIES', 'WAFER', 'MILK', 'COFFEE', 'JUICE', 'DRINK', 'SODA',
        'C2', 'GATORADE', 'COKE', 'PEPSI', 'SPRITE', 'ROYAL', 'ZESTO',
        'WATER', 'POCARI', 'RED BULL', 'ENERGY DRINK', 'STING',
        'PIATOS', 'CLOVER', 'OISHI', 'NOVA', 'CHIPPY', 'V-CUT',
        'CHEESE', 'TUNA', 'SARDINES', 'CORNED BEEF', 'MALING', 'PUREFOODS',
        'CHUCKIE', 'CORNETTO', 'SELECTA', 'ICE CREAM', 'MILO', 'NESCAFE',
        'TANG', 'HANSEL', 'FUDGEE', 'SKY FLAKES', 'CREAM-O', 'OREO',
        'GRAMS', 'CUP', 'POUCH', 'KNORR', 'MAGIC SARAP', 'DATU PUTI',
        'MANG TOMAS', 'SAUCE', 'OIL', 'VINEGAR', 'SOY SAUCE', 'PATIS',
        'CONDENSED', 'EVAPORATED', 'ALL PURPOSE CREAM', 'MARGARINE',
        'SUGAR', 'SALT', 'FLOUR', 'CORNSTARCH', 'OATS', 'ENERGEN',
        'KOPIKO', 'GREAT TASTE', 'LOADED', 'CLOUD 9', 'MENTOS'
    ]
    
    # HOUSEHOLD ITEMS
    household_keywords = [
        'TISSUE', 'WIPES', 'DETERGENT', 'SOAP', 'DISHWASHING', 'JOY',
        'SURF', 'TIDE', 'ARIEL', 'DOWNY', 'ZONROX', 'BLEACH', 'CLEANER',
        'SPONGE', 'SCOTCH BRITE', 'TOWEL', 'BAG', 'LIGHTER', 'CANDLE',
        'GLUE', 'PEN', 'BALLPEN', 'WAX', 'FEMME', 'CHAMPION'
    ]
    
    # Check categories in order of priority
    # Only pharmacy-related items get their own categories
    if any(keyword in name_upper for keyword in baby_keywords):
        return 'BABY_PRODUCTS'
    elif any(keyword in name_upper for keyword in feminine_keywords):
        return 'FEMININE_CARE'
    elif any(keyword in name_upper for keyword in medical_supply_keywords):
        return 'MEDICAL_SUPPLIES'
    elif any(keyword in name_upper for keyword in medicine_keywords):
        return 'MEDICINES'
    elif any(keyword in name_upper for keyword in personal_care_keywords):
        return 'PERSONAL_CARE'
    else:
        # All non-pharmacy items (food, beverages, household, etc.) go to OTHERS
        return 'OTHERS'

# Categorize all products
categorized = defaultdict(list)
for product in products:
    category = categorize_product(product['name'])
    categorized[category].append(product)

# Create separate CSV files for each category
for category, items in categorized.items():
    filename = f'products_{category}.csv'
    with open(filename, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Product Name', 'Stock Quantity'])
        for item in sorted(items, key=lambda x: x['name']):
            writer.writerow([item['name'], item['stock']])
    print(f'Created {filename} with {len(items)} products')

# Create summary file
with open('products_SUMMARY.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Category', 'Number of Products', 'Total Stock'])
    
    total_products = 0
    total_stock = 0
    
    for category in sorted(categorized.keys()):
        items = categorized[category]
        count = len(items)
        stock = sum(item['stock'] for item in items)
        total_products += count
        total_stock += stock
        writer.writerow([category.replace('_', ' '), count, stock])
    
    writer.writerow([''])
    writer.writerow(['TOTAL', total_products, total_stock])

print(f'\n✅ Done! Created {len(categorized)} category files')
print(f'📊 Total unique products: {len(products)}')
print(f'📦 Total stock: {sum(p["stock"] for p in products)}')
