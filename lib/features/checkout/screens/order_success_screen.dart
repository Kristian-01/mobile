import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/navigation_menu/navigation_menu.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  final String orderId;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Success Icon Animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Success Title
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Order ID
              Text(
                'Order ID: $orderId',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),

              /// Total Amount
              Text(
                'Total: ₱${totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Success Message
              Text(
                'Thank you for your order! We will send you a confirmation email shortly.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections * 2),

              /// Track Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Navigation Menu with Orders tab selected
                    Get.offAll(() => const NavigationMenu());
                    // Use Future.delayed to ensure NavigationController is initialized
                    Future.delayed(const Duration(milliseconds: 100), () {
                      try {
                        final navController = Get.find<NavigationController>();
                        navController.selectedIndex.value = 2; // Orders tab
                      } catch (e) {
                        // Fallback: Put controller if not found
                        final navController = Get.put(NavigationController());
                        navController.selectedIndex.value = 2;
                      }
                    });
                  },
                  child: const Text('Track Order'),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Home Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to Navigation Menu (Home tab)
                    Get.offAll(() => const NavigationMenu());
                    // Ensure we're on Home tab (index 0)
                    Future.delayed(const Duration(milliseconds: 100), () {
                      try {
                        final navController = Get.find<NavigationController>();
                        navController.selectedIndex.value = 0; // Home tab
                      } catch (e) {
                        // Fallback: Put controller if not found
                        final navController = Get.put(NavigationController());
                        navController.selectedIndex.value = 0;
                      }
                    });
                  },
                  child: const Text('Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
