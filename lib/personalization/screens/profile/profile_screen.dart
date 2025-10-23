import 'package:cwt_starter_template/common/widgets/images/t_rounded_image.dart';
import 'package:cwt_starter_template/personalization/controllers/theme_controller.dart';
import 'package:cwt_starter_template/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../data/repository/authentication_repository/authentication_repository.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../common/widgets/shimmers/shimmer.dart';
import '../../../features/orders/screens/orders_screen.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../features/personalization/screens/addresses/addresses_screen.dart';
import '../../../features/personalization/screens/coupons/coupons_screen.dart';
import '../../../features/personalization/screens/privacy/account_privacy_screen.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = UserController.instance;
    
    return Scaffold(
      backgroundColor: TColors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Blue Gradient Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B7FFF), Color(0xFF3D5CFF)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        Row(
                          children: [
                            /// Profile Picture
                            Obx(() {
                              final networkImage = userController.user.value.profilePicture;
                              final image = networkImage.isNotEmpty ? networkImage : TImages.tProfileImage;
                              return userController.imageUploading.value
                                  ? const TShimmerEffect(width: 60, height: 60, radius: 100)
                                  : TRoundedImage(
                                      width: 60,
                                      height: 60,
                                      isNetworkImage: networkImage.isNotEmpty,
                                      fit: BoxFit.cover,
                                      imageUrl: image,
                                      borderRadius: 30,
                                    );
                            }),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            
                            /// Name and Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                        userController.user.value.fullName.isEmpty
                                            ? 'User'
                                            : userController.user.value.fullName,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      )),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                        userController.user.value.email,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      )),
                                ],
                              ),
                            ),
                            
                            /// Edit Icon
                            IconButton(
                              onPressed: () => Get.to(() => UpdateProfileScreen()),
                              icon: const Icon(Iconsax.edit, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.defaultSpace),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// Account Settings Section with Rounded Top
            Container(
              decoration: const BoxDecoration(
                color: TColors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  _buildMenuItem(
                    context,
                    icon: Iconsax.home,
                    title: 'My Addresses',
                    subtitle: 'Set shopping delivery address',
                    onTap: () => Get.to(() => const AddressesScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subtitle: 'Add, remove products and move to checkout',
                    onTap: () => Get.toNamed(TRoutes.cartScreen),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Iconsax.bag,
                    title: 'My Orders',
                    subtitle: 'In-progress and Completed Orders',
                    onTap: () => Get.to(() => const OrdersScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Iconsax.ticket_discount,
                    title: 'My Coupons',
                    subtitle: 'List of all the discounted coupons',
                    onTap: () => Get.to(() => const CouponsScreen()),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Set any kind of notification message',
                    onTap: () => Get.toNamed(TRoutes.notification),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Iconsax.security_card,
                    title: 'Account Privacy',
                    subtitle: 'Manage data usage and connected accounts',
                    onTap: () => Get.to(() => const AccountPrivacyScreen()),
                  ),
                  
                  const SizedBox(height: TSizes.spaceBtwSections),
                  
                  /// App Settings Section
                  Text(
                    'App Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  _buildMenuItem(
                    context,
                    icon: Iconsax.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () => _showLogoutModal(),
                    titleColor: Colors.red,
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TColors.primary, size: 24),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: titleColor ?? Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TColors.grey,
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

  void _showLogoutModal() {
    Get.defaultDialog(
      title: "LOGOUT",
      titleStyle: const TextStyle(fontSize: 20),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text("Are you sure, you want to Logout?"),
      ),
      confirm: ElevatedButton(
        onPressed: () => AuthenticationRepository.instance.logout(),
        child: const Text("Yes"),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text("No"),
      ),
    );
  }
}
