import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
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
                  Iconsax.document_text,
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
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using this Pharmacy App, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms and Conditions, please do not use this app.',
            ),

            // Account Registration
            _buildSection(
              context,
              title: '2. Account Registration',
              content:
                  'To use our services, you must:\n\n'
                  '• Provide accurate and complete information\n'
                  '• Maintain the security of your account credentials\n'
                  '• Be at least 18 years old or have parental consent\n'
                  '• Have a valid prescription for prescription medications\n'
                  '• Notify us immediately of any unauthorized use of your account',
            ),

            // Services
            _buildSection(
              context,
              title: '3. Services Provided',
              content:
                  'Our app provides:\n\n'
                  '• Online pharmacy services\n'
                  '• Prescription medication ordering and delivery\n'
                  '• Over-the-counter medication sales\n'
                  '• Health and wellness products\n'
                  '• Prescription verification services\n'
                  '• Order tracking and notifications\n\n'
                  'All services are subject to product availability and prescription verification.',
            ),

            // Prescriptions
            _buildSection(
              context,
              title: '4. Prescription Requirements',
              content:
                  'For prescription medications:\n\n'
                  '• You must provide a valid prescription from a licensed healthcare provider\n'
                  '• Prescriptions will be verified by our licensed pharmacists\n'
                  '• We reserve the right to refuse any prescription we deem inappropriate\n'
                  '• Expired or invalid prescriptions will not be accepted\n'
                  '• Controlled substances require additional verification',
            ),

            // Payments
            _buildSection(
              context,
              title: '5. Payments and Pricing',
              content:
                  'Payment terms:\n\n'
                  '• All prices are subject to change without notice\n'
                  '• Payment is required before order processing\n'
                  '• We accept major credit cards and digital payment methods\n'
                  '• Prices include applicable taxes unless otherwise stated\n'
                  '• Promotional offers are subject to terms and conditions',
            ),

            // Delivery
            _buildSection(
              context,
              title: '6. Delivery and Shipping',
              content:
                  'Delivery terms:\n\n'
                  '• Delivery times are estimates and not guaranteed\n'
                  '• You must provide accurate delivery information\n'
                  '• Signature may be required for delivery\n'
                  '• We are not responsible for delays caused by third parties\n'
                  '• Shipping costs are calculated based on location and order size',
            ),

            // Returns and Refunds
            _buildSection(
              context,
              title: '7. Returns and Refunds',
              content:
                  'Return policy:\n\n'
                  '• Prescription medications cannot be returned once dispensed\n'
                  '• Unopened OTC products may be returned within 30 days\n'
                  '• Refunds will be processed to the original payment method\n'
                  '• Damaged or defective products should be reported within 48 hours\n'
                  '• Return shipping costs may apply',
            ),

            // User Conduct
            _buildSection(
              context,
              title: '8. User Conduct',
              content:
                  'You agree not to:\n\n'
                  '• Use the app for any illegal purpose\n'
                  '• Attempt to obtain medications without valid prescriptions\n'
                  '• Share your account with others\n'
                  '• Transmit harmful code or viruses\n'
                  '• Interfere with the app\'s functionality\n'
                  '• Violate any applicable laws or regulations',
            ),

            // Intellectual Property
            _buildSection(
              context,
              title: '9. Intellectual Property',
              content:
                  'All content in this app, including:\n\n'
                  '• Text, graphics, logos, images\n'
                  '• Software and app design\n'
                  '• Trademarks and service marks\n\n'
                  'are the property of our company or our licensors and are protected by copyright and trademark laws.',
            ),

            // Disclaimer
            _buildSection(
              context,
              title: '10. Disclaimer of Warranties',
              content:
                  'The app and services are provided "as is" without warranties of any kind. We do not guarantee:\n\n'
                  '• Uninterrupted or error-free operation\n'
                  '• Accuracy of information\n'
                  '• Fitness for a particular purpose\n'
                  '• Medical advice or diagnosis\n\n'
                  'Always consult healthcare professionals for medical advice.',
            ),

            // Limitation of Liability
            _buildSection(
              context,
              title: '11. Limitation of Liability',
              content:
                  'We shall not be liable for:\n\n'
                  '• Indirect, incidental, or consequential damages\n'
                  '• Loss of profits or data\n'
                  '• Personal injury or property damage\n'
                  '• Errors in medication information\n'
                  '• Third-party actions or omissions',
            ),

            // Privacy
            _buildSection(
              context,
              title: '12. Privacy',
              content:
                  'Your use of the app is also governed by our Privacy Policy. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.',
            ),

            // Modifications
            _buildSection(
              context,
              title: '13. Modifications to Terms',
              content:
                  'We reserve the right to modify these Terms and Conditions at any time. Changes will be effective immediately upon posting. Your continued use of the app after changes constitutes acceptance of the modified terms.',
            ),

            // Termination
            _buildSection(
              context,
              title: '14. Termination',
              content:
                  'We may terminate or suspend your account and access to the app:\n\n'
                  '• For violation of these terms\n'
                  '• For fraudulent or illegal activity\n'
                  '• At our sole discretion\n\n'
                  'Upon termination, your right to use the app will cease immediately.',
            ),

            // Governing Law
            _buildSection(
              context,
              title: '15. Governing Law',
              content:
                  'These Terms and Conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which we operate, without regard to its conflict of law provisions.',
            ),

            // Contact
            _buildSection(
              context,
              title: '16. Contact Information',
              content:
                  'For questions about these Terms and Conditions, contact us:\n\n'
                  '• Email: legal@pharmacyapp.com\n'
                  '• Phone: +1 (555) 123-4567\n'
                  '• Address: 123 Pharmacy Street, Medical City, MC 12345',
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Agreement
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
                      'By using our app, you agree to these Terms and Conditions in their entirety.',
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
