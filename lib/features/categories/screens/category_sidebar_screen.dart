import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../data/repository/product_repository/product_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../routes/routes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_cards/product_card_vertical.dart';
import '../../cart/controllers/cart_controller.dart';

class CategorySidebarScreen extends StatefulWidget {
  const CategorySidebarScreen({super.key});

  @override
  State<CategorySidebarScreen> createState() => _CategorySidebarScreenState();
}

class _CategorySidebarScreenState extends State<CategorySidebarScreen> {
  final CategoryController categoryController = Get.put(CategoryController());
  final ProductRepository productRepository = Get.put(ProductRepository());
  final CartController cartController = Get.put(CartController());
  
  String? selectedCategoryId;
  Stream<List<ProductModel>>? productsStream;
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  IconData _mapIconByName(String? name) {
    if (name == null) return Iconsax.category;
    switch (name) {
      case 'child_care':
        return Icons.child_care;
      case 'female':
        return Icons.female;
      case 'medication':
        return Icons.medication;
      case 'medical_services':
        return Icons.medical_services;
      case 'soap':
        return Icons.soap;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'vaccines':
        return Icons.vaccines;
      case 'sanitizer':
        return Icons.sanitizer;
      case 'category':
        return Icons.category;
      default:
        return Iconsax.category;
    }
  }

  IconData _getCategoryIcon(String id, String name, [String? iconName]) {
    if (iconName != null && iconName.isNotEmpty) {
      return _mapIconByName(iconName);
    }
    final n = name.toLowerCase();
    final i = id.toLowerCase();
    if (n.contains('baby') || i.contains('baby')) return Icons.child_care;
    if (n.contains('feminine') || n.contains('female') || i.contains('feminine') || i.contains('female')) return Icons.female;
    if (n.contains('medicine') || i.contains('medicine')) return Icons.medication;
    if (n.contains('personal care') || i.contains('personal_care') || n.contains('personal')) return Icons.soap;
    if (n.contains('medical supplies') || i.contains('medical_supplies') || n.contains('medical')) return Icons.medical_services;
    if (n.trim() == 'others' || i.trim() == 'others') return Icons.category;
    return Icons.category;
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    
    // Auto-select first category if available
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

    final bgColor = isDark ? TColors.darkBackground : Colors.white;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          /// AppBar
          Container(
            color: bgColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: TSizes.defaultSpace,
              right: TSizes.defaultSpace,
              bottom: TSizes.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : TColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(() {
                  final cartItemsCount = cartController.cartItems.length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Iconsax.shopping_cart,
                          color: isDark ? Colors.white : TColors.textPrimary,
                        ),
                        onPressed: () => Get.toNamed(TRoutes.cartScreen),
                      ),
                      if (cartItemsCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? TColors.primary : TColors.dashboardAppbarBackgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartItemsCount.toString(),
                              style: Theme.of(context).textTheme.labelSmall?.apply(
                                color: TColors.white,
                                fontSizeFactor: 0.8,
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
          ),
          /// Content Row (Fixed Sidebar + Scrollable Products)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT SIDE - Categories Sidebar (FIXED - Doesn't scroll)
                SizedBox(
                  width: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? TColors.dark : TColors.light,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? TColors.darkGrey : TColors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Obx(() {
                      if (categoryController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allCategories = categoryController.allCategories;
                      // Limit to 6 categories like the website
                      final categories = allCategories.take(6).toList();

                      if (categories.isEmpty) {
                        return const Center(
                          child: Text('No categories', textAlign: TextAlign.center),
                        );
                      }

                      return ListView.builder(
                        itemCount: categories.length,
                        padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategoryId == category.id;

                          return GestureDetector(
                            onTap: () => _selectCategory(category.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: TSizes.xs),
                              padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark 
                                        ? TColors.primary.withOpacity(0.2) 
                                        : TColors.dashboardAppbarBackgroundLight.withOpacity(0.1))
                                    : Colors.transparent,
                                border: isSelected
                                    ? Border(
                                        left: BorderSide(
                                          color: isDark ? TColors.primary : TColors.dashboardAppbarBackgroundLight,
                                          width: 3,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// Category Icon
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isDark ? TColors.darkGrey : TColors.white,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getCategoryIcon(category.id, category.name, category.icon),
                                        size: 28,
                                        color: isSelected 
                                            ? (isDark ? TColors.primary : TColors.dashboardAppbarBackgroundLight)
                                            : TColors.darkGrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: TSizes.xs),

                                  /// Category Name
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      category.name,
                                      style: Theme.of(context).textTheme.labelSmall?.apply(
                                        color: isSelected 
                                            ? (isDark ? TColors.primary : TColors.dashboardAppbarBackgroundLight)
                                            : (isDark ? TColors.light : TColors.dark),
                                        fontWeightDelta: isSelected ? 2 : 0,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),

          /// RIGHT SIDE - Products Grid
          Expanded(
            child: selectedCategoryId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.category, size: 80, color: TColors.darkGrey),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          'Select a Category',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Text(
                          'Choose a category from the left to view products',
                          style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<List<ProductModel>>(
                    stream: productsStream,
                    builder: (context, snapshot) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Error state
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.warning_2, size: 60, color: TColors.error),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Text('Error: ${snapshot.error}'),
                            ],
                          ),
                        );
                      }

                      final products = snapshot.data ?? [];

                      // Initialize products lists
                      if (allProducts.isEmpty && products.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            allProducts = products;
                            filteredProducts = products;
                          });
                        });
                      }

                      // Empty state
                      if (products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.shopping_bag, size: 80, color: TColors.darkGrey),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Text(
                                'No Products Found',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              Text(
                                'This category has no products yet',
                                style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      // Products available - show all products
                      return Column(
                        children: [
                          /// Search Bar
                          Padding(
                            padding: const EdgeInsets.all(TSizes.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    prefixIcon: const Icon(Iconsax.search_normal),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Iconsax.close_circle),
                                            onPressed: () {
                                              searchController.clear();
                                            },
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: TSizes.md,
                                      vertical: TSizes.sm,
                                    ),
                                    filled: true,
                                    fillColor: isDark ? TColors.darkGrey : TColors.light,
                                  ),
                                ),
                                const SizedBox(height: TSizes.sm),
                                // Product count indicator
                                Text(
                                  'Showing ${filteredProducts.length} of ${products.length} products',
                                  style: Theme.of(context).textTheme.bodySmall?.apply(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Products Grid (show all products)
                          Expanded(
                            child: filteredProducts.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Iconsax.search_normal_1, size: 60, color: TColors.darkGrey),
                                        const SizedBox(height: TSizes.spaceBtwItems),
                                        Text(
                                          'No results found',
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                                        Text(
                                          'Try different keywords',
                                          style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(TSizes.md),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: TSizes.gridViewSpacing,
                                      crossAxisSpacing: TSizes.gridViewSpacing,
                                      mainAxisExtent: 280,
                                    ),
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (_, index) => TProductCardVertical(
                                      product: filteredProducts[index],
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}
