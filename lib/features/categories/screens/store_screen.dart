import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../cart/screens/cart_menu_icon.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import '../../products/controllers/product_controller.dart';
import '../../products/screens/product_cards/product_card_vertical.dart';
import 'category_products_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Header - Categories Title + Cart Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(TSizes.defaultSpace, TSizes.defaultSpace * 1.5, TSizes.defaultSpace, TSizes.defaultSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: isDark ? TColors.white : TColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                  ),
                  const TCartCounterIcon(
                    iconColor: null,
                    counterBgColor: TColors.primary,
                    counterTextColor: TColors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Categories Grid
            Expanded(
              child: Obx(() {
                if (categoryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = categoryController.allCategories;

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.category,
                          size: 100,
                          color: TColors.grey,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          'No Categories Found!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: TColors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                    vertical: TSizes.sm,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                      child: _buildCategoryCard(context, category, isDark),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, dynamic category, bool isDark) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryProductsScreen(category: category));
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? TColors.dark : TColors.light,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              /// Category Icon/Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDark ? TColors.darkGrey : TColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _getCategoryIcon(category, isDark),
                ),
              ),
              const SizedBox(width: TSizes.md),
              
              /// Category Name and Arrow
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? TColors.white : TColors.darkerGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Iconsax.arrow_right_3,
                      color: isDark ? TColors.white.withValues(alpha: 0.6) : TColors.darkerGrey.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to get category icon (Material Icon or fallback)
  Widget _getCategoryIcon(dynamic category, bool isDark) {
    // Map of icon names to Material Icons
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

    // Try to get icon from category.icon field
    if (category.icon != null && iconMap.containsKey(category.icon)) {
      return Icon(
        iconMap[category.icon],
        size: 35,
        color: isDark ? TColors.light : TColors.dark,
      );
    }

    // Heuristic icon selection based on category name
    final categoryName = category.name.toLowerCase();
    IconData heuristicIcon = Icons.category;
    
    if (categoryName.contains('baby')) {
      heuristicIcon = Icons.child_care;
    } else if (categoryName.contains('feminine') || categoryName.contains('female')) {
      heuristicIcon = Icons.female;
    } else if (categoryName.contains('medicine')) {
      heuristicIcon = Icons.medication;
    } else if (categoryName.contains('personal')) {
      heuristicIcon = Icons.soap;
    } else if (categoryName.contains('medical')) {
      heuristicIcon = Icons.medical_services;
    }

    return Icon(
      heuristicIcon,
      size: 35,
      color: isDark ? TColors.light : TColors.dark,
    );
  }
}

class StoreController extends GetxController {
  final selectedCategoryId = ''.obs;
  final categoryProducts = <dynamic>[].obs;
  final isLoadingProducts = false.obs;

  final _productController = Get.put(ProductController());
  final _categoryController = Get.put(CategoryController());

  @override
  void onInit() {
    super.onInit();
    // Select first category by default
    ever(_categoryController.categories, (_) {
      if (selectedCategoryId.value.isEmpty) {
        final categories = _categoryController.getFeaturedCategories(10);
        if (categories.isNotEmpty) {
          selectCategory(categories.first.id);
        }
      }
    });

    // Initial load if categories already exist
    final categories = _categoryController.getFeaturedCategories(10);
    if (categories.isNotEmpty) {
      selectCategory(categories.first.id);
    }
  }

  void selectCategory(String categoryId) async {
    selectedCategoryId.value = categoryId;
    await loadCategoryProducts(categoryId);
  }

  Future<void> loadCategoryProducts(String categoryId) async {
    try {
      isLoadingProducts.value = true;
      final products = await _productController.fetchProductsByCategory(categoryId);
      categoryProducts.value = products;
      isLoadingProducts.value = false;
    } catch (e) {
      isLoadingProducts.value = false;
      categoryProducts.value = [];
    }
  }
}
