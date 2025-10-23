import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.black,
      appBar: AppBar(
        backgroundColor: TColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Account Privacy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data & Privacy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            _buildPrivacyOption(
              context,
              icon: Iconsax.shield_tick,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              onTap: () {},
            ),
            _buildPrivacyOption(
              context,
              icon: Iconsax.document_text,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
              onTap: () {},
            ),
            _buildPrivacyOption(
              context,
              icon: Iconsax.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {},
            ),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            Text(
              'Connected Accounts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            _buildConnectedAccount(
              context,
              icon: Icons.g_mobiledata_rounded,
              name: 'Google',
              email: 'avenido.kristian0@gmail.com',
              isConnected: true,
            ),
            _buildConnectedAccount(
              context,
              icon: Icons.facebook_rounded,
              name: 'Facebook',
              email: 'Not connected',
              isConnected: false,
            ),
            
            const SizedBox(height: TSizes.spaceBtwSections),
            
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            _buildPrivacyOption(
              context,
              icon: Iconsax.archive,
              title: 'Download My Data',
              subtitle: 'Request a copy of your data',
              onTap: () {},
            ),
            _buildPrivacyOption(
              context,
              icon: Iconsax.trash,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () {},
              titleColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(
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
                color: TColors.darkerGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: titleColor ?? TColors.primary, size: 24),
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
            const Icon(Icons.arrow_forward_ios, color: TColors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccount(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String email,
    required bool isConnected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.darkerGrey,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.darkGrey,
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
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TColors.grey,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isConnected,
            onChanged: (value) {},
            activeColor: TColors.primary,
          ),
        ],
      ),
    );
  }
}
