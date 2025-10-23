import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../models/order_model.dart';
import '../order_detail_screen.dart';

class TOrderListItem extends StatelessWidget {
  const TOrderListItem({super.key, required this.order});

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

    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.white,
      borderColor: dark ? TColors.darkGrey : TColors.grey,
      child: InkWell(
        onTap: () => Get.to(() => OrderDetailScreen(order: order)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Order ID
                Row(
                  children: [
                    const Icon(Iconsax.tag, size: 16),
                    const SizedBox(width: TSizes.spaceBtwItems / 2),
                    Text(
                      order.id,
                      style: Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 2),
                    ),
                  ],
                ),

                /// Status Badge
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

            /// Date and Payment
            Row(
              children: [
                /// Date
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar, size: 16, color: TColors.darkGrey),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Flexible(
                        child: Text(
                          order.orderDate,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Payment Method
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.wallet, size: 16, color: TColors.darkGrey),
                      const SizedBox(width: TSizes.spaceBtwItems / 2),
                      Flexible(
                        child: Text(
                          order.paymentMethod,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Total Amount and Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 2),
                ),
                const Icon(Iconsax.arrow_right_3, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
