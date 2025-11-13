import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../cart/screens/add_remove_cart_button.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';

class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final productController = ProductController.instance;
    productController.initializeAlreadyAddedProductCount(product);
    final dark = THelperFunctions.isDarkMode(context);
    
    // Check stock status
    final isOutOfStock = product.stock <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Add OR Remove Cart Product Icon Buttons
            TProductQuantityWithAddRemoveButton(
              quantity: productController.cartQuantity.value,
              // Disable add button when out of stock or quantity exceeds stock
              add: isOutOfStock || productController.cartQuantity.value >= product.stock 
                  ? null 
                  : () => productController.cartQuantity.value += 1,
              // Disable remove when cart count is less then 1
              remove: () => productController.cartQuantity.value < 1 ? null : productController.cartQuantity.value -= 1,
            ),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: isOutOfStock || productController.cartQuantity.value < 1 
                    ? null 
                    : () => productController.addProductToCart(product),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: TSizes.md, horizontal: TSizes.lg),
                  backgroundColor: isOutOfStock ? TColors.darkGrey : TColors.dark,
                  foregroundColor: TColors.white,
                  disabledBackgroundColor: TColors.darkGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOutOfStock ? Iconsax.close_circle : Iconsax.shopping_bag,
                      size: 20,
                    ), 
                    const SizedBox(width: TSizes.spaceBtwItems), 
                    Text(
                      isOutOfStock ? 'Out of Stock' : 'Add to Bag',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: TColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
