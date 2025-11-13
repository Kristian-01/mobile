#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Product Recategorization Script
================================
Automatically fixes misplaced products in CSV files based on audit findings.

Author: Cascade AI Assistant
Date: November 1, 2025
"""

import csv
import os
from collections import defaultdict

print("=" * 80)
print("🔧 PRODUCT RECATEGORIZATION SCRIPT")
print("=" * 80)
print()

# Define recategorization rules based on audit findings
RECATEGORIZATION_RULES = {
    # Products to move FROM Medicines TO Personal Care
    'MEDICINES_TO_PERSONAL_CARE': [
        'AGUA COLONIA 30 ML.',
        'BENCH COLONIA BUBLE GUM 100ML.',
        'BENCH COLONIA BUBLE GUM 50 ML.',
        'BENCH COLONIA ICE MINT 50 ML.',
        'BENCH COLONIA JELLY BEAN 100ML.',
        'BENCH COLONIA JELLY BEAN 50ML',
        'BENCH SO IN LOVE 100 ML.',
        'BENCH SO IN LOVE 50 ML.',
        'BL Cream 7g',
        'CHESTNUT SHAMPOO LIGHT BROWN 30ML.',
        'CUTICLE REMOVER 120ML.',
        'CUTICLE REMOVER 60ML.',
        'DEOPLUS DEO POWDER 40 GRAMS',
        'DEOPLUS DEODORANT SKIN LIGHT 40 GRAMS',
        'Dove Cream Bar Pink 135g',
        'Dove Shampoo\nCeramide 12ml',
        'Eskinol Calamansi 225ml',
        'Eskinol Calamansi 75ml',
        'Eskinol Mild for Teens 135ml',
        'ESKINOL CLASSIC WHITE 75 ML.',
        'GEL BLUE 50 ML.',
        'GEL GREEN 50ML.',
        'GEL YELLOW 50 ML.',
        'ICOLOR SHAMPOO CHESTNUT BROWN 30ML.',
        'Maxi-Peel Sun Protection Cream 15g',
        'Maxi-Peel Sun \nProtection Cream 15g',
        'Ponds Bright Miracle\nSerum Day Cream 7g',
        'RDL #1 Astringent 30ml',
        'RDL #1 Astringent 60ml',
        'RDL #2 Astringent 30ml',
        'RDL ASTRINGENT # 2 60 ML',
        'RDL ASTRINGENT # 3 30 ML.',
        'RDL ASTRINGENT # 3 60 ML,',
        'SKIN WHITE WHITENING LOTION 50 ML.',
        'Sunsilk Shampoo \nPink 15ml',
    ],
    
    # Products to move FROM Medicines TO Others (Food/Beverages/Household)
    'MEDICINES_TO_OTHERS': [
        'Bearbrand Adult Plus 300g',
        'Bearbrand Adult Plus 33g',
        'Bearbrand Adult Plus 600g',
        'BIGUERLAI TEA SACHET',
        'BIOFIT TEA',
        'DUTCHMILL BLUEBERRY 180 ML.',
        'DUTCHMILL STRAWBERRY 180 ML.',
        'Emperador Light 350ml',
        'FUDGEE BAR MACAPUNO',
        'Gatorade \n350ml (Blue)',
        'MAYONISE 80 ML POUCH',
        'Mega Prime Cream Style Corn 425g',
        'Nestle All Purpose Cream 250ml',
        'Pocari Sweat 350ml',
        'Pocari Sweat 500ml',
        'Pocari sweat 900 ml.',
        'WILKINS 500 ML.',
        'DOWNY SUNFRESH 24ML.',
        'SURF LIQUID CHERRY BLOSSOM 64ML.',
        'SURF LIQUID ROSE GARDEN 64ML.',
        'Surf Fabcon Blossom Fresh 28ml',
        'Surf Fabcon Blossom Fresh 69ml',
        'Surf Fabcon Luxe Perfume 28ml',
        'ZONROX COLOR SAFE 95 ML.',
        'ZONROX ORIG 500 ML.',
        'ZONROX ORIG.1000 ML.',
        'Zonrox Colorsafe 225ml',
        'Zonrox Floral Scent 250ml',
        'Zonrox Lemon Scent 250ml',
        'Zonrox Original 250ml',
        'ALPINE EVAP 360 ML.',  # Insect repellent
    ],
    
    # Products to move FROM Medicines TO Feminine Care
    'MEDICINES_TO_FEMININE_CARE': [
        'PH Care (Green)\nCooling Comfort 150ml',
        'PH Care (Green)\nCooling Comfort 50ml',
        'PH Care (Guava)\nNatural Protection 150ml',
        'PH Care (Guava)\nNatural Protection 50ml',
        'PH Care (Pink)\nFloral Clean 150ml',
        'PH Care (Pink)\nFloral Clean 50ml',
        'PH Care (Violet)\nDelicate White 150ml',
        'PH Care (Violet)\nDelicate White 50ml',
    ],
    
    # Products to move FROM Medicines TO Baby Products
    'MEDICINES_TO_BABY_PRODUCTS': [
        'Breast Pump Glass',
        'Breast Pump Plastic',
    ],
    
    # Products to move FROM Baby Products TO Medicines
    'BABY_PRODUCTS_TO_MEDICINES': [
        'Irbesartan (IRBEQ) 300mg Tablet',  # CRITICAL: Blood pressure medicine!
    ],
    
    # Products to move FROM Baby Products TO Others
    'BABY_PRODUCTS_TO_OTHERS': [
        'POTATO CHIPS BARBEQUE 22 G.',
    ],
    
    # Products to move FROM Personal Care TO Others
    'PERSONAL_CARE_TO_OTHERS': [
        'Ariel Powder Downy Floral Passion\nTripid 97g',
        'Ariel Powder Fresh Garden \nBloom Tripid 97g',
        'Ariel Powder Sunrise Fresh 97g',
        'Champion Powder w/ Fabcon 105g',
        'Surf Powder Rose Fresh 65g',
        'Surf Powder Sun Fresh 65g',
        'Tide Perfect Clean \nDowny Perfume Fantasy 74g',
        'FACIAL TISSUE SOMYTH ECO 300 P',
    ],
    
    # Products to move FROM Medical Supplies TO Personal Care
    'MEDICAL_SUPPLIES_TO_PERSONAL_CARE': [
        'BENCH COLONIA COTTON CANDY 100 ML.',
        'BENCH COLONIA COTTON CANDY 50ML.',
    ],
    
    # Products to move FROM Feminine Care TO Medical Supplies
    'FEMININE_CARE_TO_MEDICAL_SUPPLIES': [
        'Gauze Pad\n2x2 Size',
        'Gauze Pad\n3x3 Size',
        'Gauze Pad\n4x4 Size',
    ],
    
    # Products to move FROM Feminine Care TO Others
    'FEMININE_CARE_TO_OTHERS': [
        'ZIM PADS  SCRUB',  # Cleaning sponge
    ],
}

# Read all CSVs
csv_files = {
    'MEDICINES': 'products_MEDICINES.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv',
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv',
    'OTHERS': 'products_OTHERS.csv',
}

# Storage for all products
all_products = defaultdict(list)

print("📖 Reading existing CSV files...")
print("-" * 80)

# Read all existing products
for category, filename in csv_files.items():
    if not os.path.exists(filename):
        print(f"⚠️  Warning: {filename} not found, skipping...")
        continue
    
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            product_name = row['Product Name'].strip()
            stock = row['Stock Quantity'].strip()
            all_products[category].append({
                'name': product_name,
                'stock': stock
            })
    print(f"✅ Read {len(all_products[category])} products from {category}")

print()
print("🔄 Applying recategorization rules...")
print("-" * 80)

# Apply recategorization
changes_made = []

for rule_name, products_to_move in RECATEGORIZATION_RULES.items():
    source_cat, target_cat = rule_name.split('_TO_')
    
    for product_name in products_to_move:
        # Find the product in source category
        found = False
        for product in all_products[source_cat][:]:  # Create copy to iterate
            # Normalize names for comparison (handle newlines, extra spaces)
            normalized_product = product['name'].replace('\n', ' ').strip()
            normalized_search = product_name.replace('\n', ' ').strip()
            
            if normalized_product == normalized_search or product['name'] == product_name:
                # Remove from source
                all_products[source_cat].remove(product)
                # Add to target
                all_products[target_cat].append(product)
                changes_made.append(f"  ✓ {product['name']}: {source_cat} → {target_cat}")
                found = True
                break
        
        if not found:
            print(f"  ⚠️  Not found in {source_cat}: {product_name}")

print()
print(f"📝 Changes made: {len(changes_made)}")
for change in changes_made[:20]:  # Show first 20
    print(change)
if len(changes_made) > 20:
    print(f"  ... and {len(changes_made) - 20} more changes")

print()
print("💾 Writing corrected CSV files...")
print("-" * 80)

# Write corrected CSVs
for category, filename in csv_files.items():
    with open(filename, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Product Name', 'Stock Quantity'])
        
        # Sort products alphabetically
        sorted_products = sorted(all_products[category], key=lambda x: x['name'])
        
        for product in sorted_products:
            writer.writerow([product['name'], product['stock']])
    
    print(f"✅ Wrote {len(all_products[category])} products to {filename}")

print()
print("=" * 80)
print("✨ RECATEGORIZATION COMPLETE!")
print("=" * 80)
print()
print("📊 Final Category Distribution:")
print("-" * 80)
for category in sorted(csv_files.keys()):
    count = len(all_products[category])
    print(f"  {category:20s}: {count:4d} products")
print("-" * 80)
total = sum(len(products) for products in all_products.values())
print(f"  {'TOTAL':20s}: {total:4d} products")
print()
print("🔄 Next Steps:")
print("  1. Review the updated CSV files")
print("  2. Run upload script to update Firestore")
print("  3. Test the mobile app to verify categorization")
print()
