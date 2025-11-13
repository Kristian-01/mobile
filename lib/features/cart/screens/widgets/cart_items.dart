import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../../common/widgets/texts/t_product_price_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../controllers/cart_controller.dart';
import '../add_remove_cart_button.dart';
import '../cart_product_style_01.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({
    super.key,
    this.showAddRemoveButtons = true,
  });

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final cartItems = cartController.cartItems;
    final isDark = THelperFunctions.isDarkMode(context);
    return Obx(
      () {
        // Show empty state when cart is empty
        if (cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Animation
                Lottie.asset(
                  TImages.docerAnimation,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                // Title
                Text(
                  'Your Cart is Empty',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isDark ? Colors.white : TColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                // Subtitle
                Text(
                  'Add items to your cart to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwSections * 2),
                // Shop Now Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Shop Now',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show cart items
        return ListView.separated(
          shrinkWrap: true,
          itemCount: cartItems.length,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: TSizes.spaceBtwSections),
          itemBuilder: (context, index) {
          final item = cartItems[index];
          return Obx(
            () {
              final productTotal = cartController.calculateSingleProductTotal(cartItems[index].price ?? 0, cartItems[index].quantity);
              return Column(
                children: [
                  /// -- Cart Items
                  TCartItem(item: item),
                  if (showAddRemoveButtons) const SizedBox(height: TSizes.spaceBtwItems),

                  /// -- Add Remove Buttons and Price Total
                  if (showAddRemoveButtons)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// -- Add Remove Buttons
                        Row(
                          children: [
                            // Use to add space to the left of Buttons as image space.
                            const SizedBox(width: 70),

                            /// Add Remove Buttons
                            TProductQuantityWithAddRemoveButton(
                              width: 32,
                              height: 32,
                              iconSize: TSizes.md,
                              quantity: item.quantity,
                              addBackgroundColor: TColors.dashboardAppbarBackground,
                              removeForegroundColor: THelperFunctions.isDarkMode(context) ? TColors.white : TColors.black,
                              removeBackgroundColor: THelperFunctions.isDarkMode(context) ? TColors.darkerGrey : TColors.white,
                              add: () => cartController.updateCartItemQuantity(item, item.quantity + 1),
                              remove: () => cartController.updateCartItemQuantity(item, item.quantity - 1),
                            ),
                          ],
                        ),

                        /// -- Product total price
                        TProductPriceText(price: productTotal.toString()),
                      ],
                    )
                ],
              );
            },
          );
          },
        );
      },
    );
  }
}
