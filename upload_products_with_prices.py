#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Upload Products with Prices to Firestore
=========================================
Uploads products from CSV files with prices to Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
import csv
import os

# Initialize Firebase
cred = credentials.Certificate('firebase-key.json')
try:
    firebase_admin.get_app()
except:
    firebase_admin.initialize_app(cred)
db = firestore.client()

print("🔥 Connected to Firestore!")
print("=" * 80)

# Category mapping
category_mapping = {
    'MEDICINES': 'medicines',
    'BABY_PRODUCTS': 'baby_products',
    'PERSONAL_CARE': 'personal_care',
    'MEDICAL_SUPPLIES': 'medical_supplies',
    'FEMININE_CARE': 'feminine_care'
}

csv_files = {
    'MEDICINES': 'products_MEDICINES.csv',
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv'
}

print("\n💰 UPLOADING PRODUCTS WITH PRICES TO FIRESTORE")
print("-" * 80)

total_uploaded = 0
total_updated = 0
total_errors = 0
zero_price_count = 0

for category_name, filename in csv_files.items():
    if not os.path.exists(filename):
        print(f"⚠️  Skipping {category_name} - {filename} not found")
        continue
    
    print(f"\n📝 Processing: {category_name}")
    category_id = category_mapping[category_name]
    
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        category_count = 0
        
        for row in reader:
            product_name = row['Product Name'].strip()
            stock_str = row['Stock Quantity'].strip()
            price_str = row.get('Price', '0.00').strip()
            
            try:
                stock = int(stock_str)
                price = float(price_str)
                
                if price == 0 or price == 0.0:
                    zero_price_count += 1
                
                # Create product document ID (sanitize product name)
                product_id = product_name.lower().replace(' ', '_').replace('.', '').replace(',', '').replace('(', '').replace(')', '')[:50]
                
                # Prepare product data
                product_data = {
                    'title': product_name,
                    'stock': stock,
                    'price': price,
                    'categoryId': category_id,
                    'productType': 'single',
                    'isFeatured': False,
                    'thumbnail': '',
                    'images': [],
                    'description': '',
                    'brand': ''
                }
                
                # Check if product exists
                product_ref = db.collection('Products').document(product_id)
                product_doc = product_ref.get()
                
                if product_doc.exists:
                    # Update existing product
                    product_ref.update({
                        'price': price,
                        'stock': stock,
                        'title': product_name
                    })
                    total_updated += 1
                else:
                    # Create new product
                    product_ref.set(product_data)
                    total_uploaded += 1
                
                category_count += 1
                
            except Exception as e:
                print(f"   ❌ Error: {product_name} - {str(e)}")
                total_errors += 1
                continue
        
        print(f"   ✅ Processed {category_count} products from {category_name}")

print("\n" + "=" * 80)
print("📊 UPLOAD SUMMARY")
print("=" * 80)
print(f"New Products Created : {total_uploaded}")
print(f"Existing Updated     : {total_updated}")
print(f"Errors               : {total_errors}")
print(f"⚠️  Zero Price Products: {zero_price_count}")
print("-" * 80)
print(f"TOTAL PROCESSED      : {total_uploaded + total_updated}")
print("=" * 80)

if zero_price_count > 0:
    print("\n⚠️  WARNING:")
    print(f"   {zero_price_count} products uploaded with ₱0.00 price")
    print("   You may want to update prices in CSV files and re-upload")

print("\n✨ Upload complete!")
print("\n🔄 Next Steps:")
print("1. Check your Firestore console to verify products")
print("2. Test the mobile app to see products with prices")
print("3. Update CSV files with actual prices if needed")
print("4. Re-run this script to update prices in Firestore")
