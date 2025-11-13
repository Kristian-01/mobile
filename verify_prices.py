#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Verify Product Prices
======================
Checks if all products have valid prices before uploading to Firestore
"""

import csv
import os

csv_files = {
    'MEDICINES': 'products_MEDICINES.csv',
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv'
}

print("=" * 80)
print("💰 PRODUCT PRICE VERIFICATION")
print("=" * 80)
print()

total_products = 0
products_with_price = 0
products_without_price = 0
products_with_zero_price = 0

issues = []
all_prices = []

for category, filename in csv_files.items():
    if not os.path.exists(filename):
        print(f"❌ {category:20s}: FILE NOT FOUND - {filename}")
        continue
    
    print(f"📝 Checking: {category}")
    
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        category_count = 0
        category_priced = 0
        category_zero = 0
        category_missing = 0
        
        for row in reader:
            product_name = row['Product Name']
            price_str = row.get('Price', '').strip()
            
            total_products += 1
            category_count += 1
            
            if not price_str or price_str == '':
                products_without_price += 1
                category_missing += 1
                if len(issues) < 10:  # Show only first 10 issues
                    issues.append(f"  ❌ {category}: {product_name} - NO PRICE")
            else:
                try:
                    price = float(price_str)
                    if price == 0 or price == 0.0:
                        products_with_zero_price += 1
                        category_zero += 1
                    else:
                        products_with_price += 1
                        category_priced += 1
                        all_prices.append(price)
                except ValueError:
                    products_without_price += 1
                    category_missing += 1
                    if len(issues) < 10:
                        issues.append(f"  ❌ {category}: {product_name} - INVALID PRICE: {price_str}")
    
    status = "✅" if category_missing == 0 and category_zero == 0 else "⚠️"
    print(f"   {status} Total: {category_count} | Priced: {category_priced} | Zero: {category_zero} | Missing: {category_missing}")
    print()

print("=" * 80)
print("📊 SUMMARY")
print("=" * 80)
print(f"Total Products          : {total_products:4d}")
print(f"✅ With Valid Price     : {products_with_price:4d} ({products_with_price/total_products*100:.1f}%)")
print(f"⚠️  With Zero Price      : {products_with_zero_price:4d} ({products_with_zero_price/total_products*100:.1f}%)")
print(f"❌ Missing/Invalid Price: {products_without_price:4d} ({products_without_price/total_products*100:.1f}%)")
print()

if all_prices:
    print("💰 PRICE STATISTICS")
    print("-" * 80)
    print(f"Lowest Price : ₱{min(all_prices):,.2f}")
    print(f"Highest Price: ₱{max(all_prices):,.2f}")
    print(f"Average Price: ₱{sum(all_prices)/len(all_prices):,.2f}")
    print()

if issues:
    print("⚠️  ISSUES FOUND (showing first 10):")
    print("-" * 80)
    for issue in issues:
        print(issue)
    if len(issues) >= 10:
        print(f"  ... and more")
    print()

print("=" * 80)
if products_with_price == total_products:
    print("✅ ALL PRODUCTS HAVE VALID PRICES!")
    print("   Ready to upload to Firestore.")
    print()
    print("Run: python upload_products_with_prices.py")
elif products_without_price > 0:
    print("❌ SOME PRODUCTS MISSING PRICES")
    print(f"   {products_without_price} products need prices")
    print()
    print("Please update the CSV files with valid prices.")
elif products_with_zero_price > 0:
    print("⚠️  SOME PRODUCTS HAVE ZERO PRICE")
    print(f"   {products_with_zero_price} products have ₱0.00")
    print()
    print("If this is intentional, you can proceed to upload.")
    print("Otherwise, please update prices in CSV files.")
print("=" * 80)
