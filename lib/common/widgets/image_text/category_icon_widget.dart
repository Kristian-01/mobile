import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../texts/t_brand_title_text.dart';

/// Widget that displays either a Material Icon or an image for categories
class TCategoryIconWidget extends StatelessWidget {
  const TCategoryIconWidget({
    super.key,
    this.onTap,
    this.image,
    this.iconName,
    required this.title,
    this.backgroundColor,
    this.textColor,
  });

  final Color? textColor;
  final String? image;
  final String? iconName; // Material icon name (e.g., 'medication', 'child_care')
  final String title;
  final Color? backgroundColor;
  final void Function()? onTap;

  IconData? _getIconFromName(String? name) {
    if (name == null) return null;
    
    // Map of Material icon names to IconData
    final iconMap = {
      'child_care': Icons.child_care,
      'female': Icons.female,
      'medication': Icons.medication,
      'medical_services': Icons.medical_services,
      'soap': Icons.soap,
      'category': Icons.category,
      'local_hospital': Icons.local_hospital,
      'health_and_safety': Icons.health_and_safety,
      'vaccines': Icons.vaccines,
      'sanitizer': Icons.sanitizer,
    };
    
    return iconMap[name];
  }

  IconData _heuristicIcon(String title){
    final t = title.toLowerCase();
    if (t.contains('baby')) return Icons.child_care;
    if (t.contains('feminine') || t.contains('female')) return Icons.female;
    if (t.contains('medicine')) return Icons.medication;
    if (t.contains('personal')) return Icons.soap;
    if (t.contains('medical')) return Icons.medical_services;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final bgColor = backgroundColor ?? (dark ? TColors.black : TColors.white);
    final icon = _getIconFromName(iconName) ?? _heuristicIcon(title);
    // Auto text color based on theme
    final autoTextColor = textColor ?? (dark ? TColors.white : TColors.dark);
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            /// Circular Icon or Image
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: icon != null
                    ? Icon(
                        icon,
                        color: dark ? TColors.light : TColors.dark,
                        size: 28,
                      )
                    : (image != null && image!.isNotEmpty)
                        ? Image.asset(
                            image!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.category,
                              color: dark ? TColors.light : TColors.dark,
                              size: 28,
                            ),
                          )
                        : Icon(
                            Icons.category,
                            color: dark ? TColors.light : TColors.dark,
                            size: 28,
                          ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// Text
            SizedBox(
              width: 55,
              child: TBrandTitleText(
                title: title, 
                color: autoTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
