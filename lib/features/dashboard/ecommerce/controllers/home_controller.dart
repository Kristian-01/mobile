import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repository/banner_repository/banner_repository.dart';
import '../../../../data/repository/product_repository/product_repository.dart';
import '../../../products/models/product_model.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import 'categories_controller.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final _productRepository = Get.put(ProductRepository());
  final _bannerRepository = Get.put(BannerRepository());
  final carousalCurrentIndex = 0.obs;
  final featuredProducts = <ProductModel>[].obs;
  final popularProducts = <ProductModel>[].obs;
  final banners = <BannerModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🏠 HomeController initialized');
    listenToFeaturedProducts();
    listenToPopularProducts();
    fetchBanners();
  }

  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  /// Get featured categories from CategoryController
  List<CategoryModel> getFeaturedCategories() {
    final categoryController = Get.put(CategoryController());
    return categoryController.getFeaturedCategories(6);
  }

  /// Listen to featured pharmacy products real-time updates
  void listenToFeaturedProducts() {
    isLoading.value = true;
    _productRepository.getFeaturedPharmacyProductsStream().listen(
      (featured) {
        featuredProducts.value = featured;
        isLoading.value = false;
        debugPrint('📦 Featured pharmacy products updated: ${featured.length}');
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to fetch featured products: $e');
      },
    );
  }

  /// Listen to popular pharmacy products real-time updates (different from featured)
  void listenToPopularProducts() {
    _productRepository.getPopularPharmacyProductsStream().listen(
      (allPharmacyProducts) {
        // Get IDs of featured products to exclude
        final featuredIds = featuredProducts.map((p) => p.id).toList();
        
        // Filter out featured products and take 4
        final popular = allPharmacyProducts
            .where((p) => !featuredIds.contains(p.id))
            .take(4)
            .toList();
        
        popularProducts.value = popular;
        debugPrint('📦 Popular pharmacy products updated: ${popular.length}');
      },
      onError: (e) {
        Get.snackbar('Error', 'Failed to fetch popular products: $e');
      },
    );
  }

  /// Fetch featured products from Firebase (one-time fetch)
  Future<void> fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      
      // Fetch 6 featured products
      final featured = await _productRepository.fetchFeaturedProducts();
      featuredProducts.value = featured;
      
      // Fetch 6 popular products (different from featured)
      final popular = await _productRepository.fetchPopularProducts();
      popularProducts.value = popular;
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  /// Get featured products
  List<ProductModel> getFeaturedProducts() {
    return featuredProducts;
  }

  /// Get popular products
  List<ProductModel> getPopularProducts() {
    return popularProducts;
  }

  /// Fetch banners from Firebase
  Future<void> fetchBanners() async {
    try {
      debugPrint('🎯 Fetching banners from Firestore...');
      final fetchedBanners = await _bannerRepository.fetchActiveBanners();
      debugPrint('📦 Fetched ${fetchedBanners.length} banners');
      
      if (fetchedBanners.isNotEmpty) {
        banners.value = fetchedBanners;
        debugPrint('✅ Banners loaded successfully:');
        for (var banner in fetchedBanners) {
          debugPrint('   - ${banner.title}: ${banner.imageUrl}');
        }
      } else {
        debugPrint('⚠️ No banners found in Firestore');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue without banners if error occurs
    }
  }
}
