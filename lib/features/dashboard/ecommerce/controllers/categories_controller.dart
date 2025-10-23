import 'package:get/get.dart';
import '../../../../data/repository/category_repository/category_repository.dart';
import '../../../../data/repository/product_repository/product_repository.dart';
import '../../../products/models/product_model.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final _categoryRepository = Get.put(CategoryRepository());
  final _productRepository = Get.put(ProductRepository());
  
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  /// Fetch all categories from Firebase
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await _categoryRepository.getAllItems();
      categories.value = fetchedCategories;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    }
  }

  /// -- Load featured category data from Firebase
  List<CategoryModel> getFeaturedCategories(int take) {
    return categories
        .where((category) => (category.isFeatured ?? false) && category.parentId == null)
        .take(take)
        .toList();
  }

  /// -- Load sub-categories from Firebase
  List<CategoryModel> getSubCategories(String categoryId) {
    return categories.where((category) => category.parentId == categoryId).toList();
  }

  /// -- Get Sub-Category Products from Firebase
  Future<List<ProductModel>> getSubCategoryProducts(String subCategoryId, int take) async {
    try {
      final products = await _productRepository.fetchProductsByCategory(subCategoryId);
      return products.take(take).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
      return [];
    }
  }

  /// Fetch featured categories
  Future<void> fetchFeaturedCategories() async {
    try {
      isLoading.value = true;
      final featured = await _categoryRepository.fetchFeaturedCategories();
      categories.value = featured;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    }
  }
}
