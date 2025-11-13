import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';

class TProductImageSlider extends StatelessWidget {
  const TProductImageSlider({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final isDark = THelperFunctions.isDarkMode(context);
    final images = controller.getAllProductImages(product);
    return TCurvedEdgesWidget(
      child: Container(
        color: isDark ? TColors.darkerGrey : TColors.white,
        child: Stack(
          children: [
            /// Main Large Image
            SizedBox(
              height: 380,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace * 1.5),
                child: Center(
                  child: Obx(() {
                    final image = controller.selectedProductImage.value.isEmpty ? product.thumbnail : controller.selectedProductImage.value;
                    return GestureDetector(
                      onTap: () => controller.showEnlargedImage(image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                        child: Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            /// Image Slider
            if (images.length > 1)
              Positioned(
                right: 0,
                bottom: 20,
                left: TSizes.defaultSpace,
                child: SizedBox(
                  height: 70,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: images.length,
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: TSizes.spaceBtwItems),
                    itemBuilder: (_, index) {
                      return Obx(() {
                        final imageSelected = controller.selectedProductImage.value == images[index];
                        return TRoundedImage(
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                          imageUrl: images[index],
                          padding: const EdgeInsets.all(TSizes.xs),
                          backgroundColor: isDark ? TColors.dark : TColors.white,
                          isNetworkImage: true,
                          onPressed: () => controller.selectedProductImage.value = images[index],
                          border: Border.all(
                            color: imageSelected ? TColors.primary : (isDark ? TColors.darkerGrey : TColors.grey),
                            width: imageSelected ? 2.5 : 1,
                          ),
                          borderRadius: TSizes.cardRadiusMd,
                        );
                      });
                    },
                  ),
                ),
              ),

            /// Appbar Icons
            const TAppBar(showBackArrow: true, actions: [], showActions: true, showSkipButton: false),
          ],
        ),
      ),
    );
  }
}
