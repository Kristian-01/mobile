import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/order_repository/order_repository.dart';
import '../models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final _orderRepository = Get.put(OrderRepository());
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  /// Fetch user's order history from Firebase
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      
      // Fetch from Firebase
      final fetchedOrders = await _orderRepository.fetchAllItems();
      orders.value = fetchedOrders;
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to fetch orders: $e');
      print('Order fetch error: $e'); // Debug print
    }
  }

  /// Add new order to Firebase
  Future<void> addOrder(OrderModel order) async {
    try {
      final orderId = await _orderRepository.addItem(order);
      
      // Create new OrderModel with the generated ID
      final savedOrder = OrderModel(
        id: orderId,
        userId: order.userId,
        totalAmount: order.totalAmount,
        orderDate: order.orderDate,
        paymentMethod: order.paymentMethod,
        status: order.status,
        items: order.items,
        deliveryAddress: order.deliveryAddress,
      );
      
      orders.insert(0, savedOrder);
      Get.snackbar('Success', 'Order placed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e');
      print('Order creation error: $e'); // Debug print
    }
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Cancel an order (only if pending)
  Future<void> cancelOrder(OrderModel order) async {
    try {
      // Check if order can be cancelled
      if (order.status.toLowerCase() != 'pending') {
        Get.snackbar('Error', 'Cannot cancel order that is already processing');
        return;
      }

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Yes, Cancel'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Update order status to cancelled
      await _orderRepository.updateSingleField(order.id, {'status': 'cancelled'});

      // Update local list
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = OrderModel(
          id: order.id,
          userId: order.userId,
          totalAmount: order.totalAmount,
          orderDate: order.orderDate,
          paymentMethod: order.paymentMethod,
          status: 'cancelled',
          items: order.items,
          deliveryAddress: order.deliveryAddress,
        );
        orders.refresh();
      }

      Get.back(); // Close order detail screen
      Get.snackbar('Success', 'Order cancelled successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel order: $e');
      print('Order cancel error: $e');
    }
  }
}