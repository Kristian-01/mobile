import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/order_controller.dart';
import 'widgets/order_list_item.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final RxString selectedStatus = 'All'.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.black : TColors.white,
      appBar: TAppBar(
        title: Text('My Orders', style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: Column(
        children: [
          /// Scrollable Tab Bar
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTabItem(context, 'All', controller),
                _buildTabItem(context, 'Pending', controller),
                _buildTabItem(context, 'Processing', controller),
                _buildTabItem(context, 'Shipped', controller),
                _buildTabItem(context, 'Delivered', controller),
                _buildTabItem(context, 'Cancelled', controller),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.shopping_bag, size: 80, color: TColors.darkGrey),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Text(
                        'No Orders Yet',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),
                      Text(
                        'You haven\'t placed any orders',
                        style: Theme.of(context).textTheme.bodyMedium?.apply(color: TColors.darkGrey),
                      ),
                    ],
                  ),
                );
              }

              // Filter orders by selected status
              final filteredOrders = _getFilteredOrders(controller.orders, selectedStatus.value);

              return _buildOrderList(filteredOrders, 'No ${selectedStatus.value.toLowerCase()} orders');
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String status, OrderController controller) {
    return Obx(() {
      final isSelected = selectedStatus.value == status;
      final count = _getOrderCount(controller.orders, status);
      
      return GestureDetector(
        onTap: () => selectedStatus.value = status,
        child: Container(
          margin: const EdgeInsets.only(right: TSizes.spaceBtwSections),
          padding: const EdgeInsets.symmetric(horizontal: TSizes.xs),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? TColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              status == 'All' ? '$status ($count)' : '$status ($count)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? TColors.white : TColors.grey,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ),
      );
    });
  }

  List<dynamic> _getFilteredOrders(List<dynamic> orders, String status) {
    if (status == 'All') return orders;
    return orders.where((order) => order.status.toLowerCase() == status.toLowerCase()).toList();
  }

  int _getOrderCount(List<dynamic> orders, String status) {
    if (status == 'All') return orders.length;
    return orders.where((order) => order.status.toLowerCase() == status.toLowerCase()).length;
  }

  Widget _buildOrderList(List<dynamic> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.box, size: 80, color: TColors.darkGrey),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (_, index) => TOrderListItem(order: orders[index]),
    );
  }
}
