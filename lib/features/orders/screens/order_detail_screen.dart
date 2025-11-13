import 'package:flutter/material.dart';
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, bool dark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: dark ? Colors.white70 : Colors.black54),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(BuildContext context, IconData icon, String text, bool dark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: dark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    // Premium color palette (matching order list)
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    
    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B); // Amber
        statusBgColor = const Color(0xFFFEF3C7);
        statusIcon = Iconsax.clock;
        break;
      case 'processing':
        statusColor = const Color(0xFF6366F1); // Indigo
        statusBgColor = const Color(0xFFE0E7FF);
        statusIcon = Iconsax.box_tick;
        break;
      case 'shipped':
        statusColor = const Color(0xFF8B5CF6); // Violet
        statusBgColor = const Color(0xFFEDE9FE);
        statusIcon = Iconsax.truck_fast;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981); // Emerald
        statusBgColor = const Color(0xFFD1FAE5);
        statusIcon = Iconsax.tick_circle;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFF43F5E); // Rose
        statusBgColor = const Color(0xFFFFE4E6);
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFFF3F4F6);
        statusIcon = Iconsax.info_circle;
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

    final bgColor = dark ? TColors.darkBackground : Colors.white;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Order Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: dark ? Colors.white : TColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: dark ? Colors.white : TColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
            /// Order Status Header Card - Hero style
            Container(
              padding: const EdgeInsets.all(TSizes.md + 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(statusIcon, size: 28, color: Colors.white),
                      ),
                      const SizedBox(width: TSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${order.id.substring(0, order.id.length > 12 ? 12 : order.id.length)}...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.md),
                  Container(
                    padding: const EdgeInsets.all(TSizes.sm + 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                        const SizedBox(width: 8),
                        Text(
                          order.orderDate,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Section Header
            _buildSectionHeader(context, 'Order Items', Iconsax.shopping_cart, dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            ...order.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: TSizes.sm),
                  padding: const EdgeInsets.all(TSizes.md),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      /// Product Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: dark ? TColors.darkerGrey : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: item.productImage.startsWith('http')
                            ? Image.network(
                                item.productImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  Icon(Iconsax.box, color: statusColor),
                              )
                            : Image.asset(
                                item.productImage,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  Icon(Iconsax.box, color: statusColor),
                              ),
                      ),
                      const SizedBox(width: TSizes.md),

                      /// Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: TSizes.sm),

                      /// Price
                      Text(
                        '₱${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Delivery Address Section Header
            _buildSectionHeader(context, 'Delivery Address', Iconsax.location, dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(TSizes.md + 4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.user, size: 20, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: Text(
                          order.deliveryAddress.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.md),
                  _buildAddressRow(
                    context,
                    Iconsax.call,
                    order.deliveryAddress.phone,
                    dark,
                  ),
                  const SizedBox(height: TSizes.sm),
                  _buildAddressRow(
                    context,
                    Iconsax.location,
                    order.deliveryAddress.address,
                    dark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Payment Summary Section Header
            _buildSectionHeader(context, 'Payment Summary', Iconsax.wallet_2, dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(TSizes.md + 4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.wallet_3, size: 18, color: dark ? Colors.white70 : Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Method',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          order.paymentMethod,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.md),
                  Divider(
                    color: dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: TSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor,
                              statusColor.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '₱${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Order Tracking Section Header
            _buildSectionHeader(context, 'Order Tracking', Iconsax.truck_time, dark),
            const SizedBox(height: TSizes.spaceBtwItems),
            Container(
              padding: const EdgeInsets.all(TSizes.md + 4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: order.status.toLowerCase() == 'cancelled'
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Iconsax.close_circle, size: 60, color: const Color(0xFFF43F5E)),
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Text(
                              'Order Cancelled',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFFF43F5E),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            Text(
                              'This order has been cancelled',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: dark ? Colors.white60 : Colors.black54,
                              ),
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
                              ? const Color(0xFF10B981)
                              : (isCurrent ? statusColor : const Color(0xFF9CA3AF));
                          final IconData iconData = isCompleted
                              ? Iconsax.tick_circle5
                              : (isCurrent ? Iconsax.tick_circle : Iconsax.record_circle);

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
                  color: Colors.grey.withValues(alpha: 0.1),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
