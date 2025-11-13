# Quick Theme Reference

## Mga Kulay para sa Text (Light & Dark Mode)

### Para sa Normal Text:
```dart
// Use theme text styles - AUTOMATIC color adjustment
Text('Hello', style: Theme.of(context).textTheme.bodyLarge)

// Or use helper
TTextHelper.getPrimaryTextColor(context)  // Primary text
TTextHelper.getSecondaryTextColor(context)  // Secondary text
```

### Para sa Icons:
```dart
Icon(
  Iconsax.home,
  color: TTextHelper.getIconColor(context),  // Adaptive icon color
)
```

### Para sa Containers/Cards:
```dart
Container(
  color: TTextHelper.getCardColor(context),  // Adaptive card background
  child: ...
)
```

### Check kung Dark Mode:
```dart
final isDark = THelperFunctions.isDarkMode(context);
final color = isDark ? TColors.white : TColors.black;
```

## Text Sizes

- **displayLarge** - 28px (Malalaking titles)
- **headlineMedium** - 18px (Section headings)
- **titleLarge** - 16px (Card titles)
- **bodyLarge** - 14px (Regular content)
- **labelLarge** - 12px (Buttons, labels)

## Quick Examples

### ✅ Correct Way:
```dart
Text(
  'Product Name',
  style: Theme.of(context).textTheme.titleLarge,
)
```

### ❌ Wrong Way:
```dart
Text(
  'Product Name',
  style: TextStyle(color: Colors.black, fontSize: 16),
)
```
