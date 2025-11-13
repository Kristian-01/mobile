import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../data/repository/search_repository/search_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/logger_helper.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../product_cards/product_card_vertical.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchController());
    
    return Scaffold(
      appBar: TAppBar(
        title: Text('Search Products', style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: Column(
        children: [
          /// Search Bar
          Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (value) => controller.searchProducts(value),
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Iconsax.search_normal),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle),
                        onPressed: () => controller.clearSearch(),
                      )
                    : const SizedBox()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  borderSide: BorderSide(color: TColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  borderSide: BorderSide(color: TColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  borderSide: BorderSide(color: TColors.primary, width: 2),
                ),
              ),
            ),
          ),

          /// Search Results
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.search_normal_1, size: 80, color: TColors.darkGrey),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'Search for products',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'Enter product name or keywords',
                        style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.search_status, size: 80, color: TColors.darkGrey),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'No products found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'Try searching with different keywords',
                        style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.searchResults.length} products found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TGridLayout(
                      itemCount: controller.searchResults.length,
                      itemBuilder: (_, index) => TProductCardVertical(product: controller.searchResults[index]),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SearchController extends GetxController {
  static SearchController get instance => Get.find();

  final productController = ProductController.instance;
  final _searchRepository = Get.put(SearchRepository());
  final searchTextController = TextEditingController();
  final searchQuery = ''.obs;
  final searchResults = <ProductModel>[].obs;
  final recentSearches = <String>[].obs;
  final isSearching = false.obs;

  @override
  void onInit() {
    loadRecentSearches();
    super.onInit();
  }

  /// Load recent searches from Firebase
  Future<void> loadRecentSearches() async {
    try {
      recentSearches.value = await _searchRepository.fetchRecentSearches();
    } catch (e) {
      TLoggerHelper.error('Error loading recent searches', e);
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    
    // Search in all products
    final allProducts = productController.products;
    searchResults.value = allProducts.where((product) {
      final titleMatch = product.title.toLowerCase().contains(query.toLowerCase());
      final descriptionMatch = product.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final brandMatch = product.brand?.name.toLowerCase().contains(query.toLowerCase()) ?? false;
      return titleMatch || descriptionMatch || brandMatch;
    }).toList();

    isSearching.value = false;

    // Save to search history
    _searchRepository.saveSearchQuery(query);
    loadRecentSearches();
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  /// Use a recent search query
  void useRecentSearch(String query) {
    searchTextController.text = query;
    searchProducts(query);
  }

  /// Delete a specific search from history
  Future<void> deleteRecentSearch(String query) async {
    try {
      await _searchRepository.deleteSearchQuery(query);
      await loadRecentSearches();
    } catch (e) {
      TLoggerHelper.error('Error deleting search', e);
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      await _searchRepository.clearSearchHistory();
      recentSearches.clear();
      Get.snackbar(
        'Success',
        'Search history cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear search history: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
