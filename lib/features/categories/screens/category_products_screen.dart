import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../data/repository/product_repository/product_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../dashboard/ecommerce/controllers/categories_controller.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_cards/product_card_vertical.dart';

class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  final dynamic category;

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Stream<List<ProductModel>> productsStream;

  @override
  void initState() {
    super.initState();
    final productRepository = Get.put(ProductRepository());
    // Get fresh stream every time - use asBroadcastStream to allow multiple listeners
    productsStream = productRepository.getProductsByCategoryStream(widget.category.id).asBroadcastStream();
    print('🔄 Stream initialized for category: ${widget.category.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(widget.category.name, style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: StreamBuilder<List<ProductModel>>(
        key: ValueKey('products_stream_${widget.category.id}'),
        stream: productsStream,
        builder: (context, snapshot) {
          // Debug: Log every rebuild with timestamp
          final now = DateTime.now();
          print('📱 [${now.hour}:${now.minute}:${now.second}] StreamBuilder rebuilding - ConnectionState: ${snapshot.connectionState}, HasData: ${snapshot.hasData}, Products: ${snapshot.data?.length ?? 0}');
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            print('   📦 First product: ${snapshot.data!.first.title}, stock=${snapshot.data!.first.stock}, price=${snapshot.data!.first.price}');
          }
          
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

          // Products available - show all
          return SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Products',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${products.length} items',
                              style: Theme.of(context).textTheme.bodyLarge?.apply(color: TColors.darkGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.defaultSpace),

                  /// Products Grid (show all products)
                  TGridLayout(
                    itemCount: products.length,
                    mainAxisExtent: 300,
                    itemBuilder: (_, index) => TProductCardVertical(product: products[index]),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }
}
