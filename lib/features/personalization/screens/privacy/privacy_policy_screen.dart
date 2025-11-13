import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                  Iconsax.shield_tick,
                  size: 64,
                  color: TColors.primary,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Last Updated
            Center(
              child: Text(
                'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TColors.grey,
                    ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Introduction
            _buildSection(
              context,
              title: '1. Introduction',
              content:
                  'Welcome to our Pharmacy App. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),

            // Information We Collect
            _buildSection(
              context,
              title: '2. Information We Collect',
              content:
                  'We collect information that you provide directly to us, including:\n\n'
                  '• Personal Information: Name, email address, phone number, date of birth\n'
                  '• Medical Information: Prescription details, medical history, allergies\n'
                  '• Payment Information: Credit card details, billing address\n'
                  '• Location Data: Delivery address and GPS location for order delivery\n'
                  '• Device Information: Device type, operating system, unique device identifiers',
            ),

            // How We Use Your Information
            _buildSection(
              context,
              title: '3. How We Use Your Information',
              content:
                  'We use the collected information for:\n\n'
                  '• Processing and fulfilling your orders\n'
                  '• Verifying prescriptions with healthcare providers\n'
                  '• Providing customer support\n'
                  '• Sending order updates and notifications\n'
                  '• Improving our services and app functionality\n'
                  '• Complying with legal obligations',
            ),

            // Data Security
            _buildSection(
              context,
              title: '4. Data Security',
              content:
                  'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes:\n\n'
                  '• Encryption of sensitive data\n'
                  '• Secure SSL connections\n'
                  '• Regular security assessments\n'
                  '• Limited access to personal information\n'
                  '• Secure data storage facilities',
            ),

            // Data Sharing
            _buildSection(
              context,
              title: '5. Data Sharing and Disclosure',
              content:
                  'We may share your information with:\n\n'
                  '• Healthcare providers for prescription verification\n'
                  '• Payment processors for transaction processing\n'
                  '• Delivery partners for order fulfillment\n'
                  '• Legal authorities when required by law\n\n'
                  'We do not sell your personal information to third parties.',
            ),

            // Your Rights
            _buildSection(
              context,
              title: '6. Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate information\n'
                  '• Request deletion of your data\n'
                  '• Object to data processing\n'
                  '• Export your data\n'
                  '• Withdraw consent at any time',
            ),

            // Cookies and Tracking
            _buildSection(
              context,
              title: '7. Cookies and Tracking Technologies',
              content:
                  'We use cookies and similar tracking technologies to track activity on our app and store certain information. This helps us:\n\n'
                  '• Remember your preferences\n'
                  '• Understand how you use our app\n'
                  '• Improve user experience\n'
                  '• Provide personalized content',
            ),

            // Children's Privacy
            _buildSection(
              context,
              title: '8. Children\'s Privacy',
              content:
                  'Our service is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),

            // Changes to Policy
            _buildSection(
              context,
              title: '9. Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.',
            ),

            // Contact Us
            _buildSection(
              context,
              title: '10. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  '• Email: support@pharmacyapp.com\n'
                  '• Phone: +1 (555) 123-4567\n'
                  '• Address: 123 Pharmacy Street, Medical City, MC 12345',
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Acceptance
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(color: TColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: TColors.primary),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Text(
                      'By using our app, you acknowledge that you have read and understood this Privacy Policy.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
      ],
    );
  }
}
