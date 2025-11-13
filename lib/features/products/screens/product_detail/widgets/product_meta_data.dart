import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../common/widgets/texts/t_brand_title_text_with_verified_icon.dart';
import '../../../../../common/widgets/texts/t_product_price_text.dart';
import '../../../../../common/widgets/texts/t_product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';

class TProductMetaData extends StatelessWidget {
  const TProductMetaData({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePercentage = ProductController.instance.calculateSalePercentage(product.price, product.salePrice);
    final darkMode = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Price & Sale Price
        Row(
          children: [
            /// -- Sale Tag
            if (salePercentage != null)
              Row(
                children: [
                  TRoundedContainer(
                    backgroundColor: TColors.primary,
                    radius: TSizes.borderRadiusMd,
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
                    child: Text('$salePercentage%',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: TColors.black, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems)
                ],
              ),


            // Actual Price if sale price not null.
            if (product.productVariations == null && product.salePrice != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.price.toString(), style: Theme.of(context).textTheme.titleMedium!.apply(decoration: TextDecoration.lineThrough, color: TColors.darkGrey),),
                  const SizedBox(width: TSizes.spaceBtwItems)
                ],
              ),

            // Price, Show sale price as main price if sale exist.
            TProductPriceText(price: controller.getProductPrice(product), isLarge: true),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        TProductTitleText(title: product.title),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          children: [
            Text('Stock: ', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: TColors.darkGrey)),
            Text(
              controller.getProductStockStatus(product), 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Brand (only show if brand exists)
        if (product.brand != null)
          Row(
            children: [
              TCircularImage(
                image: product.brand!.image,
                width: 32,
                height: 32,
                overlayColor: darkMode ? TColors.white : TColors.black,
              ),
              TBrandTitleWithVerifiedIcon(title: product.brand!.name, brandTextSize: TextSizes.medium),
            ],
          ),
      ],
    );
  }
}
