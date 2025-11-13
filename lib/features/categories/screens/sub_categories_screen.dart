import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import 'category_products_screen.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final subCategories = controller.getSubCategories(categoryId);

    return Scaffold(
      appBar: TAppBar(
        title: Text(categoryName, style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: subCategories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.box_1, size: 80, color: TColors.darkGrey),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    'No Sub-Categories',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Text(
                    'This category has no sub-categories yet',
                    style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sub-Categories',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Text(
                    'Select a sub-category to view products',
                    style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Sub-Category Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subCategories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: TSizes.gridViewSpacing,
                      crossAxisSpacing: TSizes.gridViewSpacing,
                      mainAxisExtent: 140,
                    ),
                    itemBuilder: (_, index) {
                      final subCategory = subCategories[index];
                      return _SubCategoryCard(
                        subCategory: subCategory,
                        onTap: () => Get.to(() => CategoryProductsScreen(
                              category: subCategory,
                            )),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  const _SubCategoryCard({
    required this.subCategory,
    required this.onTap,
  });

  final dynamic subCategory;
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
    final icon = _getIconFromName(subCategory.icon) ?? _heuristicIcon(subCategory.name);

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
            /// Sub-Category Icon
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

            /// Sub-Category Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
              child: Text(
                subCategory.name,
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
