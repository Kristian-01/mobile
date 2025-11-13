# Real-Time Sync Testing Guide

## How to Test Real-Time Updates

### Setup:
1. **Open Desktop App** - Inventory Management
2. **Open Mobile App** - Navigate to Categories → Baby Products
3. **Open Flutter Console** - To see debug logs

### Test Steps:

#### Test 1: Stock Update (Out of Stock)
1. **Mobile**: Note the current stock of "EQ Pants L/40"
2. **Desktop**: Click "Edit" on "EQ Pants L/40"
3. **Desktop**: Change QTY from 100 to 0
4. **Desktop**: Click "Save"
5. **Mobile**: Watch for:
   - Console: `🔥 Firebase snapshot received`
   - Console: `📱 StreamBuilder rebuilding`
   - UI: "OUT OF STOCK" badge should appear immediately
   - UI: Product card should have red overlay
   - UI: Add button should show ❌ icon

#### Test 2: Price Update
1. **Mobile**: Note the current price of "EQ Pants L/40" (₱0.0)
2. **Desktop**: Click "Edit" on "EQ Pants L/40"
3. **Desktop**: Change PRICE from 0.00 to 25.00
4. **Desktop**: Click "Save"
5. **Mobile**: Watch for:
   - Console: `🔥 Firebase snapshot received`
   - Console: `   Sample product: ... price=25.0`
   - UI: Price should update to ₱25

#### Test 3: Stock Restore
1. **Mobile**: "EQ Pants L/40" should show "OUT OF STOCK"
2. **Desktop**: Click "Edit" on "EQ Pants L/40"
3. **Desktop**: Change QTY from 0 to 50
4. **Desktop**: Click "Save"
5. **Mobile**: Watch for:
   - UI: "OUT OF STOCK" badge disappears immediately
   - UI: Add button shows + icon again
   - UI: Product can be added to cart

### Debug Console Output:

When working correctly, you should see:

```
🔥 Setting up Firebase stream for category: baby_products
🔥 Firebase snapshot received: 10 products, fromCache: false
   Sample product: EQ Pants L/40, stock=0, price=0.0
📱 StreamBuilder rebuilding - ConnectionState: ConnectionState.active, HasData: true, Products: 10
   First product: EQ Pants L/40, stock=0, price=0.0
```

When desktop updates product:
```
🔥 Firebase snapshot received: 10 products, fromCache: false
   Sample product: EQ Pants L/40, stock=50, price=25.0
📱 StreamBuilder rebuilding - ConnectionState: ConnectionState.active, HasData: true, Products: 10
   First product: EQ Pants L/40, stock=50, price=25.0
```

### Troubleshooting:

**If updates don't appear:**

1. **Check Firebase Console** - Verify data updated in Firestore
2. **Check Mobile Internet** - Ensure device has internet connection
3. **Restart Mobile App** - Sometimes needed after code changes
4. **Check Console Logs** - Look for error messages
5. **Verify Category ID** - Ensure product has correct `categoryId` field

**Common Issues:**

- **Cached Data**: Clear app data if showing old info
- **Wrong Category**: Product must match category filter
- **Network**: Requires active internet on mobile device
- **Firebase Rules**: Must allow read access to Products collection

### Expected Behavior:

✅ **Real-Time** - Updates appear within 1-2 seconds
✅ **Automatic** - No manual refresh needed
✅ **Bidirectional** - Desktop → Mobile, instant sync
✅ **Multiple Fields** - Stock, price, all fields sync
✅ **UI Updates** - Out of stock badge, prices, everything
