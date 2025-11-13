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
    listenToCategories();
    super.onInit();
  }

  /// Listen to categories real-time updates from Firebase
  void listenToCategories() {
    isLoading.value = true;
    _categoryRepository.getCategoriesStream().listen(
      (fetchedCategories) {
        // Remove duplicates by keeping only unique category names
        final Map<String, CategoryModel> uniqueCategories = {};
        for (var category in fetchedCategories) {
          // Use category name as key to ensure uniqueness
          final key = category.name.toLowerCase();
          // Keep the first occurrence or the one with proper ID
          if (!uniqueCategories.containsKey(key) || 
              category.id == key.replaceAll(' ', '_')) {
            uniqueCategories[key] = category;
          }
        }
        
        final uniqueList = uniqueCategories.values.toList();
        print('📦 Found ${fetchedCategories.length} → ${uniqueList.length} unique categories');
        
        // ✅ FILTER: Only show pharmacy-related categories
        final pharmacyCategories = [
          'baby products',
          'baby_products',
          'feminine care',
          'feminine_care',
          'female care',
          'female_care',
          'medicines',
          'medicine',
          'medical supplies',
          'medical_supplies',
          'personal care',
          'personal_care',
          'multivitamins',
          'vitamins',
          'topical_oral',
          'topical',
          'oral',
          'cough_cold',
          'cough',
          'cold'
        ];
        
        final filteredList = uniqueList.where((category) {
          final categoryName = category.name.toLowerCase();
          final categoryId = category.id.toLowerCase();
          
          // Check if category name or ID matches pharmacy categories
          return pharmacyCategories.any((pharma) => 
            categoryName.contains(pharma) || categoryId.contains(pharma.replaceAll(' ', '_'))
          );
        }).toList();
        
        final filteredCount = uniqueList.length - filteredList.length;
        if (filteredCount > 0) {
          print('🚫 Filtered out $filteredCount non-pharmacy categories');
        }
        
        // Sort categories: 'Others' always last, rest alphabetically
        filteredList.sort((a, b) {
          // If 'a' is Others, it should come after 'b'
          if (a.name.toLowerCase() == 'others') return 1;
          // If 'b' is Others, it should come after 'a'
          if (b.name.toLowerCase() == 'others') return -1;
          // Otherwise sort alphabetically
          return a.name.compareTo(b.name);
        });
        
        categories.value = filteredList;
        isLoading.value = false;
        print('✅ Pharmacy categories: ${filteredList.map((c) => c.name).join(", ")}');
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to fetch categories: $e');
      },
    );
  }

  /// Fetch all categories from Firebase (one-time fetch)
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final fetchedCategories = await _categoryRepository.getAllItems();
      
      // ✅ FILTER: Only show pharmacy-related categories
      final pharmacyCategories = [
        'baby products',
        'baby_products',
        'feminine care',
        'feminine_care',
        'female care',
        'female_care',
        'medicines',
        'medicine',
        'medical supplies',
        'medical_supplies',
        'personal care',
        'personal_care',
        'multivitamins',
        'vitamins',
        'topical_oral',
        'topical',
        'oral',
        'cough_cold',
        'cough',
        'cold'
      ];
      
      final filteredCategories = fetchedCategories.where((category) {
        final categoryName = category.name.toLowerCase();
        final categoryId = category.id.toLowerCase();
        
        return pharmacyCategories.any((pharma) => 
          categoryName.contains(pharma) || categoryId.contains(pharma.replaceAll(' ', '_'))
        );
      }).toList();
      
      // Sort categories: 'Others' always last, rest alphabetically
      filteredCategories.sort((a, b) {
        // If 'a' is Others, it should come after 'b'
        if (a.name.toLowerCase() == 'others') return 1;
        // If 'b' is Others, it should come after 'a'
        if (b.name.toLowerCase() == 'others') return -1;
        // Otherwise sort alphabetically
        return a.name.compareTo(b.name);
      });
      
      categories.value = filteredCategories;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    }
  }

  /// Get all categories (Others always last)
  List<CategoryModel> get allCategories {
    final sortedCategories = List<CategoryModel>.from(categories);
    sortedCategories.sort((a, b) {
      // If 'a' is Others, it should come after 'b'
      if (a.name.toLowerCase() == 'others') return 1;
      // If 'b' is Others, it should come after 'a'
      if (b.name.toLowerCase() == 'others') return -1;
      // Otherwise sort alphabetically
      return a.name.compareTo(b.name);
    });
    return sortedCategories;
  }

  /// -- Load featured category data from Firebase (max 6 main categories)
  List<CategoryModel> getFeaturedCategories(int take) {
    // Only get main categories (no parent) that are featured
    final featured = categories
        .where((category) => (category.isFeatured ?? false) && category.parentId == null)
        .toList();
    
    // Sort: 'Others' always last, rest alphabetically
    featured.sort((a, b) {
      if (a.name.toLowerCase() == 'others') return 1;
      if (b.name.toLowerCase() == 'others') return -1;
      return a.name.compareTo(b.name);
    });
    
    // Limit to maximum of 6 categories for pharmacy
    final maxCategories = take > 6 ? 6 : take;
    return featured.take(maxCategories).toList();
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
