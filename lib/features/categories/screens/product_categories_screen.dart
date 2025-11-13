import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import 'category_products_screen.dart';

class ProductCategoriesScreen extends StatelessWidget {
  const ProductCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final categories = controller.getFeaturedCategories(8);

    return Scaffold(
      appBar: TAppBar(
        title: Text('Store', style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: false,
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Categories',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              'Choose a category to browse products',
              style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Category Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: TSizes.gridViewSpacing,
                crossAxisSpacing: TSizes.gridViewSpacing,
                mainAxisExtent: 140,
              ),
              itemBuilder: (_, index) {
                final category = categories[index];
                return _CategoryCard(
                  category: category,
                  onTap: () => Get.to(() => CategoryProductsScreen(category: category)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final dynamic category;
  final VoidCallback onTap;

  /// Get Material Icon from icon name
  IconData? _getIconFromName(String? name) {
    if (name == null) return null;
    
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

  /// Heuristic icon selection based on category name
  IconData _heuristicIcon(String title) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _getIconFromName(category.icon) ?? _heuristicIcon(category.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          color: isDark ? TColors.darkerGrey : TColors.lightContainer,
          border: Border.all(color: isDark ? TColors.darkGrey : TColors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Category Icon
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: isDark ? TColors.dark : TColors.white,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isDark ? TColors.light : TColors.dark,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
