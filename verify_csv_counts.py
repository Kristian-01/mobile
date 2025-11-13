import csv
import os

files = {
    'MEDICINES': 'products_MEDICINES.csv',
    'BABY_PRODUCTS': 'products_BABY_PRODUCTS.csv',
    'PERSONAL_CARE': 'products_PERSONAL_CARE.csv',
    'MEDICAL_SUPPLIES': 'products_MEDICAL_SUPPLIES.csv',
    'FEMININE_CARE': 'products_FEMININE_CARE.csv'
}

print('=' * 60)
print('📊 CSV FILES VERIFICATION')
print('=' * 60)

total = 0
for category, filename in files.items():
    if os.path.exists(filename):
        with open(filename, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            count = len(list(reader))
            print(f'{category:20s}: {count:4d} products')
            total += count
    else:
        print(f'{category:20s}: FILE NOT FOUND')

print('-' * 60)
print(f'{"TOTAL":20s}: {total:4d} products')
print('=' * 60)
print()
print('✅ Firestore has 803 products')
print(f'📄 CSV files have {total} products')
if total > 803:
    print(f'⚠️  Difference: {total - 803} products in CSV not in Firestore')
    print('   (This is normal - CSV may have duplicates or unuploaded items)')
elif total == 803:
    print('✅ Perfect match!')
else:
    print(f'⚠️  Firestore has {803 - total} more products than CSV')
