import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Tracking steps based on current order status
    final List<String> steps = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    int currentStepIndex;
    switch (order.status.toLowerCase()) {
      case 'pending':
        currentStepIndex = 0;
        break;
      case 'processing':
        currentStepIndex = 1;
        break;
      case 'shipped':
        currentStepIndex = 2;
        break;
      case 'delivered':
        currentStepIndex = 3;
        break;
      case 'cancelled':
        currentStepIndex = -1; // Special case for cancelled
        break;
      default:
        currentStepIndex = 0;
    }

    return Scaffold(
      appBar: TAppBar(
        title: Text('Order Details', style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Order Status Card
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.white,
              borderColor: statusColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order ID: ${order.id}',
                          style: Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar, size: 16, color: TColors.darkGrey),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Text(
                        'Order Date: ${order.orderDate}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Items List
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                  child: TRoundedContainer(
                    showBorder: true,
                    padding: const EdgeInsets.all(TSizes.sm),
                    backgroundColor: dark ? TColors.dark : TColors.white,
                    borderColor: dark ? TColors.darkGrey : TColors.grey,
                    child: Row(
                      children: [
                        /// Product Image
                        TRoundedContainer(
                          width: 60,
                          height: 60,
                          backgroundColor: dark ? TColors.darkerGrey : TColors.lightContainer,
                          child: item.productImage.startsWith('http')
                              ? Image.network(
                                  item.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.box),
                                )
                              : Image.asset(
                                  item.productImage,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Iconsax.box),
                                ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),

                        /// Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                              ),
                            ],
                          ),
                        ),

                        /// Price
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 2),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Delivery Address
            Text(
              'Delivery Address',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.white,
              borderColor: dark ? TColors.darkGrey : TColors.grey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.deliveryAddress.name,
                    style: Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: TColors.darkGrey),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Text(
                        order.deliveryAddress.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: TColors.darkGrey),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Expanded(
                        child: Text(
                          order.deliveryAddress.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Payment Summary
            Text(
              'Payment Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.white,
              borderColor: dark ? TColors.darkGrey : TColors.grey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method:', style: Theme.of(context).textTheme.bodyMedium),
                      Text(order.paymentMethod, style: Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2)),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount:', style: Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 2)),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.apply(fontWeightDelta: 2, color: TColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Order Tracking
            Text(
              'Order Tracking',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.dark : TColors.white,
              borderColor: dark ? TColors.darkGrey : TColors.grey,
              child: order.status.toLowerCase() == 'cancelled'
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
                        child: Column(
                          children: [
                            Icon(Icons.cancel, size: 60, color: Colors.red),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Text(
                              'Order Cancelled',
                              style: Theme.of(context).textTheme.titleLarge?.apply(color: Colors.red, fontWeightDelta: 2),
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            Text(
                              'This order has been cancelled',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...List.generate(steps.length, (index) {
                          final bool isCompleted = index < currentStepIndex;
                          final bool isCurrent = index == currentStepIndex;
                          final Color iconColor = isCompleted
                              ? Colors.green
                              : (isCurrent ? TColors.primary : TColors.darkGrey);
                          final IconData iconData = isCompleted
                              ? Icons.check_circle
                              : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked);

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(iconData, color: iconColor),
                                title: Text(
                                  steps[index],
                                  style: isCurrent
                                      ? Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2)
                                      : Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: index == 0
                                    ? Text('Order placed, waiting for confirmation', style: Theme.of(context).textTheme.bodySmall)
                                    : null,
                              ),
                              if (index != steps.length - 1) const Divider(height: 8),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Cancel Order Button (only show if pending)
            if (order.status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final controller = OrderController.instance;
                    controller.cancelOrder(order);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Order'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                  ),
                ),
              )
            else if (order.status.toLowerCase() != 'cancelled')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TSizes.sm),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Order cannot be cancelled once processing',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
