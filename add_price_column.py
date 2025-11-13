#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Add Price Column to CSV Files
==============================
Adds a Price column to all product CSV files with default value of 0.00
"""

import csv
import os

csv_files = [
    'products_MEDICINES.csv',
    'products_BABY_PRODUCTS.csv',
    'products_PERSONAL_CARE.csv',
    'products_MEDICAL_SUPPLIES.csv',
    'products_FEMININE_CARE.csv'
]

print("=" * 80)
print("💰 ADDING PRICE COLUMN TO CSV FILES")
print("=" * 80)
print()

for filename in csv_files:
    if not os.path.exists(filename):
        print(f"⚠️  Skipping {filename} - file not found")
        continue
    
    print(f"📝 Processing: {filename}")
    
    # Read existing data
    products = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            products.append(row)
    
    # Create backup
    backup_filename = filename.replace('.csv', '_BACKUP.csv')
    os.rename(filename, backup_filename)
    print(f"   ✅ Backup created: {backup_filename}")
    
    # Write with new Price column
    with open(filename, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['Product Name', 'Stock Quantity', 'Price']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        
        for product in products:
            writer.writerow({
                'Product Name': product['Product Name'],
                'Stock Quantity': product['Stock Quantity'],
                'Price': '0.00'  # Default price
            })
    
    print(f"   ✅ Updated with Price column ({len(products)} products)")
    print()

print("=" * 80)
print("✨ PRICE COLUMN ADDED TO ALL FILES!")
print("=" * 80)
print()
print("📝 Next Steps:")
print("1. Open each CSV file in Excel/Google Sheets")
print("2. Fill in the actual prices for each product")
print("3. Save the files")
print("4. Run upload script to update Firestore with prices")
print()
print("💡 TIP: You can use Excel formulas or bulk edit to speed up pricing")
print()
print("📄 Backup files created (in case you need to restore):")
for filename in csv_files:
    backup = filename.replace('.csv', '_BACKUP.csv')
    if os.path.exists(backup):
        print(f"   - {backup}")
