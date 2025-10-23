import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../product_cards/product_card_vertical.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({
    super.key,
    required this.title,
    this.products,
    this.categoryId,
  });

  final String title;
  final List<ProductModel>? products;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());
    
    // Initialize with provided products or fetch all
    if (products != null) {
      controller.setProducts(products!);
    } else if (categoryId != null) {
      controller.fetchProductsByCategory(categoryId!);
    } else {
      controller.fetchAllProducts();
    }

    return Scaffold(
      appBar: TAppBar(
        title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: Column(
        children: [
          /// Search Bar
          Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Obx(() => TextField(
                  onChanged: (value) => controller.searchProducts(value),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () => controller.searchProducts(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: TSizes.md,
                      vertical: TSizes.sm,
                    ),
                  ),
                )),
          ),

          /// Filters and Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Product Count
                Obx(() => Text(
                      '${controller.displayedProducts.length} Products',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),

                /// Sort Button
                Row(
                  children: [
                    /// Filter Button
                    IconButton(
                      icon: const Icon(Iconsax.filter),
                      onPressed: () => _showFilterBottomSheet(context, controller),
                    ),
                    
                    /// Sort Dropdown
                    Obx(() => DropdownButton<SortOption>(
                          value: controller.currentSortOption.value,
                          icon: const Icon(Iconsax.arrow_down_1),
                          underline: const SizedBox(),
                          onChanged: (SortOption? value) {
                            if (value != null) {
                              controller.sortProducts(value);
                            }
                          },
                          items: SortOption.values.map((SortOption option) {
                            return DropdownMenuItem<SortOption>(
                              value: option,
                              child: Text(
                                option.label,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                        )),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          /// Products Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.displayedProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.searchQuery.value.isNotEmpty
                            ? Iconsax.search_normal_1
                            : Iconsax.box,
                        size: 80,
                        color: TColors.darkGrey,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No Search Results'
                            : 'No Products Found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Try searching with different keywords'
                            : 'Try adjusting your filters',
                        style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: TGridLayout(
                  itemCount: controller.displayedProducts.length,
                  itemBuilder: (_, index) => TProductCardVertical(
                    product: controller.displayedProducts[index],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, AllProductsController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Price Range Filter
            Text('Price Range', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Obx(() => RangeSlider(
                  values: RangeValues(
                    controller.minPrice.value,
                    controller.maxPrice.value,
                  ),
                  min: 0,
                  max: controller.absoluteMaxPrice.value,
                  divisions: 20,
                  labels: RangeLabels(
                    '₱${controller.minPrice.value.round()}',
                    '₱${controller.maxPrice.value.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    controller.minPrice.value = values.start;
                    controller.maxPrice.value = values.end;
                  },
                )),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₱${controller.minPrice.value.round()}'),
                    Text('₱${controller.maxPrice.value.round()}'),
                  ],
                )),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Featured Filter
            Obx(() => CheckboxListTile(
                  title: const Text('Featured Products Only'),
                  value: controller.showFeaturedOnly.value,
                  onChanged: (value) {
                    controller.showFeaturedOnly.value = value ?? false;
                  },
                  contentPadding: EdgeInsets.zero,
                )),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SortOption {
  nameAZ,
  nameZA,
  priceLowHigh,
  priceHighLow,
  newest,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.nameAZ:
        return 'Name: A-Z';
      case SortOption.nameZA:
        return 'Name: Z-A';
      case SortOption.priceLowHigh:
        return 'Price: Low to High';
      case SortOption.priceHighLow:
        return 'Price: High to Low';
      case SortOption.newest:
        return 'Newest First';
    }
  }
}

class AllProductsController extends GetxController {
  static AllProductsController get instance => Get.find();

  final allProducts = <ProductModel>[].obs;
  final displayedProducts = <ProductModel>[].obs;
  final isLoading = false.obs;

  // Filters
  final currentSortOption = SortOption.nameAZ.obs;
  final minPrice = 0.0.obs;
  final maxPrice = 10000.0.obs;
  final absoluteMaxPrice = 10000.0.obs;
  final showFeaturedOnly = false.obs;
  final searchQuery = ''.obs;

  void setProducts(List<ProductModel> products) {
    allProducts.value = products;
    displayedProducts.value = products;
    _calculatePriceRange();
  }

  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      final controller = Get.find<ProductController>();
      await controller.fetchProducts();
      allProducts.value = controller.products;
      displayedProducts.value = allProducts;
      _calculatePriceRange();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      final controller = Get.find<ProductController>();
      final products = await controller.fetchProductsByCategory(categoryId);
      allProducts.value = products;
      displayedProducts.value = products;
      _calculatePriceRange();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  void _calculatePriceRange() {
    if (allProducts.isEmpty) return;
    
    final prices = allProducts.map((p) => p.price).toList();
    minPrice.value = prices.reduce((a, b) => a < b ? a : b);
    maxPrice.value = prices.reduce((a, b) => a > b ? a : b);
    absoluteMaxPrice.value = maxPrice.value;
  }

  void sortProducts(SortOption option) {
    currentSortOption.value = option;
    
    switch (option) {
      case SortOption.nameAZ:
        displayedProducts.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameZA:
        displayedProducts.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.priceLowHigh:
        displayedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        displayedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        displayedProducts.sort((a, b) {
          if (a.date == null || b.date == null) return 0;
          return b.date!.compareTo(a.date!);
        });
        break;
    }
    displayedProducts.refresh();
  }

  void applyFilters() {
    displayedProducts.value = allProducts.where((product) {
      // Price filter
      if (product.price < minPrice.value || product.price > maxPrice.value) {
        return false;
      }

      // Featured filter
      if (showFeaturedOnly.value && !(product.isFeatured ?? false)) {
        return false;
      }

      return true;
    }).toList();

    // Re-apply current sort
    sortProducts(currentSortOption.value);
  }

  void clearFilters() {
    _calculatePriceRange();
    showFeaturedOnly.value = false;
    displayedProducts.value = allProducts;
    sortProducts(currentSortOption.value);
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // If search is empty, apply current filters
      applyFilters();
    } else {
      // Filter by search query first
      final searchLower = query.toLowerCase();
      displayedProducts.value = allProducts.where((product) {
        // Check if product matches search query
        if (!product.title.toLowerCase().contains(searchLower)) {
          return false;
        }

        // Then apply other filters
        if (product.price < minPrice.value || product.price > maxPrice.value) {
          return false;
        }

        if (showFeaturedOnly.value && !(product.isFeatured ?? false)) {
          return false;
        }

        return true;
      }).toList();

      // Apply current sort
      sortProducts(currentSortOption.value);
    }
  }
}
