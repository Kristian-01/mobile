import 'package:get/get.dart';
import '../../../../data/repository/product_repository/product_repository.dart';
import '../../../products/models/product_model.dart';
import '../models/category_model.dart';
import 'categories_controller.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final _productRepository = Get.put(ProductRepository());
  final carousalCurrentIndex = 0.obs;
  final featuredProducts = <ProductModel>[].obs;
  final popularProducts = <ProductModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchFeaturedProducts();
    super.onInit();
  }

  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  /// Get featured categories from CategoryController
  List<CategoryModel> getFeaturedCategories() {
    final categoryController = Get.put(CategoryController());
    return categoryController.getFeaturedCategories(8);
  }

  /// Fetch featured products from Firebase
  Future<void> fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      
      // Fetch 6 featured products
      final featured = await _productRepository.fetchFeaturedProducts();
      featuredProducts.value = featured;
      
      // Fetch 8 popular products (different from featured)
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
}
