import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/image_text/image_text_vertical.dart';
import '../../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../categories/screens/category_products_screen.dart';
import '../../../../../categories/screens/store_screen.dart';
import '../../../controllers/categories_controller.dart';

class THeaderCategories extends StatelessWidget {
  const THeaderCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    
    return Padding(
      padding: const EdgeInsets.only(left: TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// -- Heading
          TSectionHeading(
            title: 'Popular Categories',
            textColor: TColors.white,
            showActionButton: true,
            onPressed: () => Get.to(() => const StoreScreen()),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// -- Categories (Reactive to Firebase data)
          Obx(() {
            if (categoryController.isLoading.value) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              );
            }

            final categories = categoryController.getFeaturedCategories(8);
            
            if (categories.isEmpty) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    'No categories yet',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 80,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return TVerticalImageAndText(
                    image: category.image,
                    title: category.name,
                    onTap: () => Get.to(() => CategoryProductsScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    )),
                  );
                },
              ),
            );
          })
        ],
      ),
    );
  }
}
