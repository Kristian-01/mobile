import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

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
          'My Coupons',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            _buildCouponCard(
              context,
              code: 'SAVE20',
              discount: '20% OFF',
              description: 'Get 20% off on orders above ₱500',
              expiryDate: 'Valid till: Dec 31, 2025',
              isActive: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildCouponCard(
              context,
              code: 'FIRST50',
              discount: '₱50 OFF',
              description: 'First order discount',
              expiryDate: 'Valid till: Nov 30, 2025',
              isActive: true,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildCouponCard(
              context,
              code: 'FREESHIP',
              discount: 'FREE SHIPPING',
              description: 'Free shipping on all orders',
              expiryDate: 'Expired: Oct 15, 2025',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context, {
    required String code,
    required String discount,
    required String description,
    required String expiryDate,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : TColors.darkGrey,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.ticket_discount,
                      color: isActive ? Colors.white : TColors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discount,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: isActive ? Colors.white : TColors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isActive ? Colors.white70 : TColors.darkGrey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withValues(alpha: 0.2) : TColors.darkerGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? Colors.white.withValues(alpha: 0.3) : TColors.darkGrey,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isActive ? Colors.white : TColors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Iconsax.copy,
                        size: 16,
                        color: isActive ? Colors.white : TColors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(
                  expiryDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive ? Colors.white70 : TColors.grey,
                      ),
                ),
              ],
            ),
          ),
          if (!isActive)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'EXPIRED',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
