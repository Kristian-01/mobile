import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/header_categories.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/header_search_container.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/home_appbar.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/promo_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../cart/controllers/cart_controller.dart';
import '../../../../categories/screens/store_screen.dart';
import '../../../../products/controllers/product_controller.dart';
import '../../../../products/screens/product_cards/product_card_vertical.dart';
import '../../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    Get.put(CartController());
    Get.put(ProductController());
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            const TPrimaryHeaderContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -- Appbar
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Searchbar
                  TSearchContainer(text: 'Search in Store', showBorder: false),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Categories
                  THeaderCategories(),
                  SizedBox(height: TSizes.spaceBtwSections * 2),
                ],
              ),
            ),

            /// -- Body
            Container(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -- Promo Slider 1 - Pharmacy Banners
                  const TPromoSlider(banners: [
                    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=300&fit=crop',
                    'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800&h=300&fit=crop',
                    'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800&h=300&fit=crop',
                  ]),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Featured Products (Reactive to Firebase)
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final featuredProducts = controller.featuredProducts;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TSectionHeading(
                          title: 'Featured Products',
                          onPressed: () => Get.to(() => const StoreScreen()),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        featuredProducts.isEmpty
                            ? const Center(child: Text('No featured products yet'))
                            : TGridLayout(
                                itemCount: featuredProducts.length,
                                itemBuilder: (_, index) => TProductCardVertical(product: featuredProducts[index]),
                              ),
                      ],
                    );
                  }),
                  const SizedBox(height: TSizes.spaceBtwSections * 2),

                  /// -- Promo Slider 2 - Health & Wellness
                  const TPromoSlider(banners: [
                    'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&h=300&fit=crop',
                    'https://images.unsplash.com/photo-1550572017-4240fe2fd0b6?w=800&h=300&fit=crop',
                    'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&h=300&fit=crop',
                  ]),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Popular Products (Reactive to Firebase)
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final popularProducts = controller.popularProducts;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TSectionHeading(
                          title: TTexts.popularProducts,
                          onPressed: () => Get.to(() => const StoreScreen()),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        popularProducts.isEmpty
                            ? const Center(child: Text('No popular products yet'))
                            : TGridLayout(
                                itemCount: popularProducts.length,
                                itemBuilder: (_, index) => TProductCardVertical(product: popularProducts[index]),
                              ),
                      ],
                    );
                  }),
                  SizedBox(height: TDeviceUtils.getBottomNavigationBarHeight() + TSizes.defaultSpace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
