import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';

class UpdateDOBScreen extends StatelessWidget {
  const UpdateDOBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = Rx<DateTime?>(null);
    
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
          'Update Date of Birth',
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
              'Select your date of birth',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.grey,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            Obx(() => InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  selectedDate.value = picked;
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.grey),
                  borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.calendar),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate.value == null
                          ? 'Select Date'
                          : DateFormat('d MMM, yyyy').format(selectedDate.value!),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDate.value != null) {
                    final formattedDate = DateFormat('d MMM, yyyy').format(selectedDate.value!);
                    controller.updateDateOfBirth(formattedDate);
                  } else {
                    Get.snackbar('Error', 'Please select a date');
                  }
                },
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
