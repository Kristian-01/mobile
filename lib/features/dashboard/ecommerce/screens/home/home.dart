import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/header_categories.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/header_search_container.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/home_appbar.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/promo_slider.dart';
import 'package:cwt_starter_template/features/dashboard/ecommerce/screens/home/widgets/prescription_upload_card.dart';
import 'package:cwt_starter_template/features/prescriptions/screens/prescription_upload_screen.dart';
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
import '../../../../navigation_menu/navigation_menu.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF02040A) : Colors.white,
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
              color: isDark ? const Color(0xFF02040A) : Colors.white,
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -- Prescription Upload Card
                  GestureDetector(
                    onTap: () => Get.to(() => const PrescriptionUploadScreen()),
                    child: const TPrescriptionUploadCard(),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Promo Slider 1 - Top Banners (3)
                  TPromoSlider(banners: [
                    TImages.banner1,
                    TImages.banner2,
                    TImages.banner3,
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
                          onPressed: () {
                            final navController = Get.find<NavigationController>();
                            navController.selectedIndex.value = 1; // Switch to Categories tab
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        featuredProducts.isEmpty
                            ? Center(child: Text('No featured products yet', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)))
                            : TGridLayout(
                                itemCount: featuredProducts.length,
                                itemBuilder: (_, index) => TProductCardVertical(product: featuredProducts[index]),
                              ),
                      ],
                    );
                  }),
                  const SizedBox(height: TSizes.spaceBtwSections * 2),

                  /// -- Promo Slider 2 - Bottom Banners (2)
                  TPromoSlider(banners: [
                    TImages.banner4,
                    TImages.banner5,
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
                          title: 'Popular Products',
                          onPressed: () {
                            final navController = Get.find<NavigationController>();
                            navController.selectedIndex.value = 1; // Switch to Categories tab
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        popularProducts.isEmpty
                            ? Center(child: Text('No popular products yet', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)))
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
