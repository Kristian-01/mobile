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
  void initState() {
    super.initState();
    // Ensure we fetch orders immediately on screen open in case
    // the real-time stream is delayed or auth state hasn't emitted yet.
    Future.microtask(() {
      final controller = Get.put(OrderController());
      controller.refreshOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? TColors.darkBackground : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'My Orders',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : TColors.textPrimary,
              ),
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: Container(
                color: bgColor,
                padding: const EdgeInsets.only(
                  left: TSizes.defaultSpace,
                  right: TSizes.defaultSpace,
                  bottom: TSizes.sm,
                ),
                height: 65,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTabItem(context, 'All', controller),
                    const SizedBox(width: 8),
                    _buildTabItem(context, 'Pending', controller),
                    const SizedBox(width: 8),
                    _buildTabItem(context, 'Processing', controller),
                    const SizedBox(width: 8),
                    _buildTabItem(context, 'Shipped', controller),
                    const SizedBox(width: 8),
                    _buildTabItem(context, 'Delivered', controller),
                    const SizedBox(width: 8),
                    _buildTabItem(context, 'Cancelled', controller),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
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
    );
  }

  Widget _buildTabItem(BuildContext context, String status, OrderController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      final isSelected = selectedStatus.value == status;
      final count = _getOrderCount(controller.orders, status);
      
      // Premium color palette matching order items
      Color statusColor;
      switch (status.toLowerCase()) {
        case 'pending':
          statusColor = const Color(0xFFF59E0B);
          break;
        case 'processing':
          statusColor = const Color(0xFF6366F1);
          break;
        case 'shipped':
          statusColor = const Color(0xFF8B5CF6);
          break;
        case 'delivered':
          statusColor = const Color(0xFF10B981);
          break;
        case 'cancelled':
          statusColor = const Color(0xFFF43F5E);
          break;
        default:
          statusColor = const Color(0xFF14B8A6); // Teal for "All"
      }
      
      return GestureDetector(
        onTap: () => selectedStatus.value = status,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? statusColor
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? statusColor
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$status ($count)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.3,
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
