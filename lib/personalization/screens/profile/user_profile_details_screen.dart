import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widgets/images/t_rounded_image.dart';
import '../../../common/widgets/shimmers/shimmer.dart';
import '../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';
import 'update_name_screen.dart';
import 'update_username_screen.dart';
import 'update_email_screen.dart';
import 'update_phone_number_screen.dart';
import 'update_gender_screen.dart';
import 'update_dob_screen.dart';

class UserProfileDetailsScreen extends StatelessWidget {
  const UserProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? TColors.white : TColors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = userController.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage : TImages.tProfileImage;
                      return userController.imageUploading.value
                          ? const TShimmerEffect(width: 100, height: 100, radius: 100)
                          : TRoundedImage(
                              width: 100,
                              height: 100,
                              isNetworkImage: networkImage.isNotEmpty,
                              fit: BoxFit.cover,
                              imageUrl: image,
                              borderRadius: 50,
                            );
                    }),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TextButton(
                      onPressed: () => _showImagePickerOptions(context, userController),
                      child: Text(
                        'Change Profile Picture',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: TColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              /// Divider
              Divider(color: isDark ? TColors.darkGrey : TColors.grey.withValues(alpha: 0.3)),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              /// Profile Information Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              _buildProfileField(
                context,
                label: 'Name',
                value: Obx(() => Text(
                  userController.user.value.fullName.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.fullName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                )),
                onTap: () => Get.to(() => const UpdateNameScreen()),
              ),
              
              _buildProfileField(
                context,
                label: 'Username',
                value: Obx(() => Text(
                  userController.user.value.username.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.username,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                )),
                onTap: () => Get.to(() => const UpdateUsernameScreen()),
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
              
              /// Divider
              Divider(color: isDark ? TColors.darkGrey : TColors.grey.withValues(alpha: 0.3)),
              
              const SizedBox(height: TSizes.spaceBtwItems),
              
              /// Personal Information Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              
              _buildProfileField(
                context,
                label: 'User ID',
                value: Obx(() => Row(
                  children: [
                    Expanded(
                      child: Text(
                        userController.user.value.id.isEmpty 
                            ? 'Not set' 
                            : userController.user.value.id.substring(0, 6),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? TColors.white : TColors.black,
                            ),
                      ),
                    ),
                    Icon(
                      Iconsax.copy,
                      size: 20,
                      color: isDark ? TColors.white : TColors.black,
                    ),
                  ],
                )),
                onTap: () {
                  // Copy to clipboard
                  // Clipboard.setData(ClipboardData(text: userController.user.value.id));
                  Get.snackbar('Copied', 'User ID copied to clipboard');
                },
              ),
              
              _buildProfileField(
                context,
                label: 'E-mail',
                value: Obx(() => Text(
                  userController.user.value.email.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                  overflow: TextOverflow.ellipsis,
                )),
                onTap: () => Get.to(() => const UpdateEmailScreen()),
              ),
              
              _buildProfileField(
                context,
                label: 'Phone Number',
                value: Obx(() => Text(
                  userController.user.value.phoneNumber.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                )),
                onTap: () => Get.to(() => const UpdatePhoneNumberScreen()),
              ),
              
              _buildProfileField(
                context,
                label: 'Gender',
                value: Obx(() => Text(
                  userController.user.value.gender.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.gender,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                )),
                onTap: () => Get.to(() => const UpdateGenderScreen()),
              ),
              
              _buildProfileField(
                context,
                label: 'Date of Birth',
                value: Obx(() => Text(
                  userController.user.value.dateOfBirth.isEmpty 
                      ? 'Not set' 
                      : userController.user.value.dateOfBirth,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? TColors.white : TColors.black,
                      ),
                )),
                onTap: () => Get.to(() => const UpdateDOBScreen()),
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections * 2),
              
              /// Close Account Button
              Center(
                child: TextButton(
                  onPressed: () => _showCloseAccountDialog(context),
                  child: const Text(
                    'Close Account',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required String label,
    required Widget value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TColors.grey,
                    ),
              ),
            ),
            Expanded(
              flex: 3,
              child: value,
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 20,
              color: isDark ? TColors.white : TColors.black,
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, UserController userController) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                userController.uploadUserProfilePicture(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                userController.uploadUserProfilePicture(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseAccountDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Close Account",
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          "Are you sure you want to close your account? This action cannot be undone.",
          textAlign: TextAlign.center,
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          // TODO: Implement account deletion
          Get.back();
          AuthenticationRepository.instance.deleteAccount();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text("Yes, Close Account"),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }
}
