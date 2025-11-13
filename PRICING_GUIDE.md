# 💰 PRODUCT PRICING GUIDE
**Date:** November 1, 2025  
**Status:** Ready for Price Input

---

## ✅ PRICE COLUMN ADDED!

All CSV files now have a **Price** column with default value of ₱0.00:

```csv
Product Name,Stock Quantity,Price
ALCANFORADO 60 ML.,5,0.00
ALNIX PLUS 60ML,2,0.00
Biogesic 500mg,500,0.00
```

---

## 📊 FILES UPDATED

| File | Products | Status |
|------|----------|--------|
| `products_MEDICINES.csv` | 516 | ✅ Price column added |
| `products_BABY_PRODUCTS.csv` | 133 | ✅ Price column added |
| `products_PERSONAL_CARE.csv` | 105 | ✅ Price column added |
| `products_MEDICAL_SUPPLIES.csv` | 58 | ✅ Price column added |
| `products_FEMININE_CARE.csv` | 33 | ✅ Price column added |
| **TOTAL** | **845** | **Ready for pricing** |

---

## 📝 HOW TO ADD PRICES

### Method 1: Using Excel (Recommended)

1. **Open CSV file** in Microsoft Excel
   - Right-click CSV file → Open With → Excel
   - Or drag file into Excel

2. **Edit prices** in the Price column
   ```
   Product Name              | Stock | Price
   ───────────────────────────────────────────
   Biogesic 500mg           | 500   | 5.50
   Amoxicillin 500mg        | 699   | 12.00
   Paracetamol Syrup 60ml   | 11    | 95.00
   ```

3. **Save as CSV**
   - File → Save As
   - Format: CSV UTF-8 (Comma delimited) (*.csv)
   - ⚠️ Important: Keep the CSV format!

4. **Repeat** for all 5 category files

### Method 2: Using Google Sheets

1. **Upload CSV** to Google Drive
2. **Open with** Google Sheets
3. **Edit prices** in column C
4. **Download as CSV**
   - File → Download → Comma-separated values (.csv)

### Method 3: Bulk Import from Price List

If you have an existing price list:
1. Save as CSV with format: `Product Name,Price`
2. Run the `import_prices.py` script (will create this if needed)

---

## 💡 PRICING TIPS

### Sample Pricing (for reference)
```
Category: MEDICINES
─────────────────────────────────────
Biogesic 500mg Tab           ₱5.50
Amoxicillin 500mg Capsule    ₱12.00
Paracetamol Syrup 60ml       ₱95.00
Cetirizine 10mg Tablet       ₱6.00
Vitamin C 500mg              ₱8.00

Category: BABY_PRODUCTS
─────────────────────────────────────
Baby Oil 50ml                ₱85.00
Baby Powder 25g              ₱45.00
Baby Wipes 11 sheets         ₱35.00
Ceelin Drops 15ml            ₱185.00

Category: PERSONAL_CARE
─────────────────────────────────────
Colgate Toothpaste 20g       ₱75.00
Safeguard Soap 60g           ₱35.00
Shampoo Sachet 15ml          ₱8.00
```

### Pricing Strategy
- **Medicines:** Check SRP (Suggested Retail Price)
- **Generic vs Branded:** Price accordingly
- **Bulk items:** May have lower per-unit price
- **Imported items:** Usually higher priced
- **Promotional items:** Consider discount pricing

---

## 🔄 AFTER ADDING PRICES

Once you've filled in all prices:

### Step 1: Verify your CSV files
```bash
python verify_prices.py
```

### Step 2: Upload to Firestore
```bash
python upload_products_with_prices.py
```

This will:
- ✅ Read all CSV files with prices
- ✅ Update Firestore products with actual prices
- ✅ Verify all 845 products have prices
- ✅ Generate price report

---

## 📋 BACKUP FILES

Original files (without Price column) backed up:
- `products_MEDICINES_BACKUP.csv`
- `products_BABY_PRODUCTS_BACKUP.csv`
- `products_PERSONAL_CARE_BACKUP.csv`
- `products_MEDICAL_SUPPLIES_BACKUP.csv`
- `products_FEMININE_CARE_BACKUP.csv`

⚠️ **Don't delete these!** You can restore if needed.

---

## ⚠️ IMPORTANT NOTES

1. **Price Format:** Use numbers only (e.g., `5.50` not `₱5.50` or `5.50 pesos`)
2. **Decimal Points:** Use period `.` not comma `,` (e.g., `5.50` not `5,50`)
3. **No commas in numbers:** Write `1500.00` not `1,500.00`
4. **Save as CSV:** Always save in CSV format, not Excel (.xlsx)
5. **UTF-8 Encoding:** Make sure to save as UTF-8 to preserve special characters

---

## 🆘 TROUBLESHOOTING

### Problem: Excel changes prices to dates
**Solution:** Format Price column as Number before entering data
- Select column C → Right-click → Format Cells → Number → 2 decimal places

### Problem: CSV file looks corrupted after saving
**Solution:** Save as "CSV UTF-8 (Comma delimited)"
- Not just "CSV (Comma delimited)"

### Problem: Special characters (₱, ñ) disappeared
**Solution:** Use UTF-8 encoding when saving

---

## 📊 PROGRESS TRACKER

Track your pricing progress:

```
[ ] products_MEDICINES.csv         (516 products)
[ ] products_BABY_PRODUCTS.csv     (133 products)
[ ] products_PERSONAL_CARE.csv     (105 products)
[ ] products_MEDICAL_SUPPLIES.csv  (58 products)
[ ] products_FEMININE_CARE.csv     (33 products)
```

**Estimated Time:** ~2-4 hours (depending on how you get prices)

---

## 🎯 NEXT SCRIPT TO RUN

After pricing all products, I'll create:
- `verify_prices.py` - Check if all products have prices
- `upload_products_with_prices.py` - Upload to Firestore with prices
- `price_report.py` - Generate pricing summary

---

**Need Help?** Just ask! 😊
