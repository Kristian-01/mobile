import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/account_privacy_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountPrivacyController());

    return Scaffold(
      backgroundColor: TColors.black,
      appBar: AppBar(
        backgroundColor: TColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.lock,
                  size: 64,
                  color: TColors.primary,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Info Text
            Text(
              'Secure Your Account',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              'Choose a strong password to keep your account safe and secure.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TColors.grey,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Form
            Form(
              key: controller.changePasswordFormKey,
              child: Column(
                children: [
                  // Current Password
                  Obx(
                    () => TextFormField(
                      controller: controller.currentPassword,
                      obscureText: controller.hideCurrentPassword.value,
                      validator: (value) => TValidator.validateEmptyText('Current password', value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: TextStyle(color: TColors.grey),
                        prefixIcon: Icon(Iconsax.password_check, color: TColors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.hideCurrentPassword.value ? Iconsax.eye_slash : Iconsax.eye,
                            color: TColors.grey,
                          ),
                          onPressed: () => controller.hideCurrentPassword.value = !controller.hideCurrentPassword.value,
                        ),
                        filled: true,
                        fillColor: TColors.darkerGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // New Password
                  Obx(
                    () => TextFormField(
                      controller: controller.newPassword,
                      obscureText: controller.hideNewPassword.value,
                      validator: (value) => TValidator.validatePassword(value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: TColors.grey),
                        prefixIcon: Icon(Iconsax.lock, color: TColors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.hideNewPassword.value ? Iconsax.eye_slash : Iconsax.eye,
                            color: TColors.grey,
                          ),
                          onPressed: () => controller.hideNewPassword.value = !controller.hideNewPassword.value,
                        ),
                        filled: true,
                        fillColor: TColors.darkerGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Confirm New Password
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPassword,
                      obscureText: controller.hideConfirmPassword.value,
                      validator: (value) {
                        if (value != controller.newPassword.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(color: TColors.grey),
                        prefixIcon: Icon(Iconsax.lock, color: TColors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.hideConfirmPassword.value ? Iconsax.eye_slash : Iconsax.eye,
                            color: TColors.grey,
                          ),
                          onPressed: () => controller.hideConfirmPassword.value = !controller.hideConfirmPassword.value,
                        ),
                        filled: true,
                        fillColor: TColors.darkerGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.darkGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                          borderSide: BorderSide(color: TColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Password Requirements
                  Container(
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                      border: Border.all(color: TColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.info_circle, color: TColors.primary, size: 20),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text(
                              'Password Requirements',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: TColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        _buildRequirement('At least 6 characters long'),
                        _buildRequirement('Mix of uppercase and lowercase letters'),
                        _buildRequirement('At least one number'),
                        _buildRequirement('At least one special character'),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.changePasswordFunc(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight / 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                        ),
                      ),
                      child: Text(
                        'Change Password',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: TSizes.spaceBtwItems, top: 4),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            color: TColors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: TColors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
