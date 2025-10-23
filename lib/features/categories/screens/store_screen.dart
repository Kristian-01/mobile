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

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    final storeController = Get.put(StoreController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Header - Store Title + Cart Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(TSizes.defaultSpace, TSizes.defaultSpace * 1.5, TSizes.defaultSpace, TSizes.defaultSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Store',
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

            /// Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: TSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? TColors.darkGrey : TColors.grey),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.search_normal,
                      color: isDark ? TColors.darkGrey : TColors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Text(
                      'Search in Store',
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: isDark ? TColors.darkGrey : TColors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections * 1.5),

            /// Featured Brands Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Brands',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: TColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'View all',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TColors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems * 1.5),

            /// Featured Brands Display
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Center(
                child: Text(
                  'No Data Found!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TColors.grey,
                      ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections * 1.5),

            /// Category Tabs
            Obx(() {
              if (categoryController.isLoading.value) {
                return const SizedBox.shrink();
              }

              final categories = categoryController.getFeaturedCategories(10);

              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Obx(() {
                      final isSelected = storeController.selectedCategoryId.value == category.id;
                      return GestureDetector(
                        onTap: () => storeController.selectCategory(category.id),
                        child: Container(
                          margin: const EdgeInsets.only(right: TSizes.spaceBtwSections),
                          padding: const EdgeInsets.symmetric(horizontal: TSizes.xs),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? TColors.primary : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isSelected ? TColors.white : TColors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Products Grid
            Expanded(
              child: Obx(() {
                if (storeController.isLoadingProducts.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = storeController.categoryProducts;

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No Data Found!',
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                            color: isDark ? TColors.darkGrey : TColors.grey,
                          ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                  child: TGridLayout(
                    itemCount: products.length,
                    itemBuilder: (_, index) => TProductCardVertical(product: products[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
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
