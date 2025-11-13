import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../data/repository/product_repository/product_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../routes/routes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import '../../products/models/product_model.dart';
import '../../products/models/product_variation_model.dart';
import '../../cart/controllers/cart_controller.dart';

/// Modern Category Browse Screen with Horizontal Category Selector
/// This is a UI redesign with no backend changes
class ModernCategoryBrowseScreen extends StatefulWidget {
  const ModernCategoryBrowseScreen({super.key});

  @override
  State<ModernCategoryBrowseScreen> createState() => _ModernCategoryBrowseScreenState();
}

class _ModernCategoryBrowseScreenState extends State<ModernCategoryBrowseScreen> {
  final CategoryController categoryController = Get.put(CategoryController());
  final ProductRepository productRepository = Get.put(ProductRepository());
  final CartController cartController = Get.put(CartController());
  
  String? selectedCategoryId;
  Stream<List<ProductModel>>? productsStream;
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  /// Map icon names to Material Icons (SAME AS HOME POPULAR CATEGORIES)
  IconData? _getIconFromName(String? name) {
    if (name == null) return null;
    
    // Map of Material icon names to IconData
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

  /// Heuristic icon selection (SAME AS HOME POPULAR CATEGORIES)
  IconData _heuristicIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('baby')) return Icons.child_care;
    if (t.contains('feminine') || t.contains('female')) return Icons.female;
    if (t.contains('medicine')) return Icons.medication;
    if (t.contains('personal')) return Icons.soap;
    if (t.contains('medical')) return Icons.medical_services;
    return Icons.category;
  }

  /// Get category icon (SAME LOGIC AS HOME POPULAR CATEGORIES)
  IconData _getCategoryIcon(String iconName, String title) {
    final icon = _getIconFromName(iconName) ?? _heuristicIcon(title);
    return icon;
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    
    // Auto-select first category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = categoryController.allCategories;
      if (categories.isNotEmpty) {
        _selectCategory(categories.first.id);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      productsStream = productRepository.getProductsByCategoryStream(categoryId);
      allProducts = [];
      filteredProducts = [];
      searchController.clear();
    });
  }

  void _onSearchChanged() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredProducts = allProducts;
      } else {
        filteredProducts = allProducts
            .where((product) => product.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.black : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            /// Modern Header with Title and Cart
            _buildHeader(context, isDark),
            
            /// Horizontal Category Selector (Scrollable Pills)
            _buildCategorySelector(isDark),
            
            /// Products Grid
            Expanded(
              child: _buildProductsSection(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Header Section
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? TColors.dark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Browse our products',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
          Obx(() {
            final cartItemsCount = cartController.cartItems.length;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? TColors.darkGrey : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Iconsax.shopping_cart,
                      color: isDark ? Colors.white : TColors.dark,
                    ),
                    onPressed: () => Get.toNamed(TRoutes.cartScreen),
                  ),
                ),
                if (cartItemsCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        cartItemsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Horizontal Category Selector (Modern Pills with Icons)
  Widget _buildCategorySelector(bool isDark) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? TColors.dark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = categoryController.allCategories.take(6).toList();

        if (categories.isEmpty) {
          return const Center(child: Text('No categories'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: TSizes.defaultSpace,
            vertical: TSizes.sm,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategoryId == category.id;
            final icon = _getCategoryIcon(category.icon ?? '', category.name);

            return GestureDetector(
              onTap: () => _selectCategory(category.id),
              child: Container(
                margin: const EdgeInsets.only(right: TSizes.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.md,
                  vertical: TSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? TColors.primary 
                      : (isDark ? TColors.darkGrey : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: isSelected 
                          ? Colors.white 
                          : (isDark ? Colors.white70 : TColors.dark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? Colors.white70 : TColors.dark),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// Products Section with Search and Grid
  Widget _buildProductsSection(bool isDark) {
    if (selectedCategoryId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.category, size: 80, color: Colors.grey[400]),
            const SizedBox(height: TSizes.md),
            Text(
              'Select a Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<ProductModel>>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.warning_2, size: 60, color: TColors.error),
                const SizedBox(height: TSizes.md),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        // Initialize products
        if (allProducts.isEmpty && products.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              allProducts = products;
              filteredProducts = products;
            });
          });
        }

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shopping_bag, size: 80, color: Colors.grey[400]),
                const SizedBox(height: TSizes.md),
                Text(
                  'No Products Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            /// Search Bar
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? TColors.darkGrey : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TSizes.md,
                    vertical: TSizes.sm,
                  ),
                ),
              ),
            ),

            /// Product Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Row(
                children: [
                  Text(
                    'Showing ${filteredProducts.length} of ${products.length} products',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.sm),

            /// Modern Products Grid (2 Columns)
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.search_normal_1, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: TSizes.md),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: TSizes.gridViewSpacing,
                        crossAxisSpacing: TSizes.gridViewSpacing,
                        mainAxisExtent: 280,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (_, index) {
                        final product = filteredProducts[index];
                        return _buildModernProductCard(product, isDark);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Modern Product Card Design
  Widget _buildModernProductCard(ProductModel product, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Image
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? TColors.darkGrey : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      product.thumbnail,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.box,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              
              /// Sale Badge (if on sale)
              if (product.salePrice != null && product.salePrice! > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SALE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Product Title
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : TColors.dark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  /// Stock Status
                  Text(
                    product.stock > 0 ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 10,
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  
                  /// Price and Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.salePrice != null && product.salePrice! > 0) ...[
                            Text(
                              '₱${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '₱${product.salePrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? TColors.primary : TColors.dark,
                              ),
                            ),
                          ] else
                            Text(
                              '₱${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? TColors.primary : TColors.dark,
                              ),
                            ),
                        ],
                      ),
                      
                      /// Add to Cart Button
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Iconsax.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (product.stock > 0) {
                              cartController.addSingleItemToCart(product, ProductVariationModel.empty());
                              Get.snackbar(
                                'Success',
                                '${product.title} added to cart',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(TSizes.sm),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
