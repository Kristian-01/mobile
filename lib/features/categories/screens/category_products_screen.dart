import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_cards/product_card_vertical.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<List<ProductModel>> productsFuture;
  final TextEditingController searchController = TextEditingController();
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    final controller = Get.put(CategoryController());
    // Fetch all products in this category
    productsFuture = controller.getSubCategoryProducts(widget.categoryId, 10000);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    return Scaffold(
      appBar: TAppBar(
        title: Text(widget.categoryName, style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: productsFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final products = snapshot.data ?? [];
          
          // Initialize products lists
          if (allProducts.isEmpty && products.isNotEmpty) {
            allProducts = products;
            filteredProducts = products;
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
                  ),
                ],
              ),
            );
          }

          // Products available
          return SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Search Bar
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
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Header with count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Products',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredProducts.length} of ${products.length} items',
                            style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Products Grid (Filtered)
                  filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: TSizes.spaceBtwSections * 2),
                              Icon(Iconsax.search_normal_1, size: 80, color: TColors.darkGrey),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Text(
                                'No results found',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems / 2),
                              Text(
                                'Try searching with different keywords',
                                style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                              ),
                            ],
                          ),
                        )
                      : TGridLayout(
                          itemCount: filteredProducts.length,
                          itemBuilder: (_, index) => TProductCardVertical(product: filteredProducts[index]),
                        ),
                ],
              ),
            );
        },
      ),
    );
  }
}
