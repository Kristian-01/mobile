import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';

class UpdateGenderScreen extends StatelessWidget {
  const UpdateGenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedGender = controller.user.value.gender.obs;
    
    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? TColors.black : TColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? TColors.white : TColors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Update Gender',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? TColors.white : TColors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your gender',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.grey,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            Obx(() => Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'Male',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                  fillColor: WidgetStateProperty.all(TColors.primary),
                ),
                RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'Female',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                  fillColor: WidgetStateProperty.all(TColors.primary),
                ),
                RadioListTile<String>(
                  title: const Text('Other'),
                  value: 'Other',
                  groupValue: selectedGender.value,
                  onChanged: (value) => selectedGender.value = value!,
                  fillColor: WidgetStateProperty.all(TColors.primary),
                ),
              ],
            )),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateGender(selectedGender.value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
