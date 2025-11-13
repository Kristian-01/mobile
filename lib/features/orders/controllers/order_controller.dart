import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repository/order_repository/order_repository.dart';
import '../models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final _orderRepository = Get.put(OrderRepository());
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  @override
  void onInit() {
    startRealtimeListener();
    super.onInit();
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  /// Start real-time listener for orders
  void startRealtimeListener() {
    try {
      isLoading.value = true;
      print('🎯 OrderController: Starting real-time listener...');
      
      // Set a timeout to prevent infinite loading
      Future.delayed(const Duration(seconds: 5), () {
        if (isLoading.value) {
          print('⚠️ OrderController: Loading timeout - setting to false');
          isLoading.value = false;
        }
      });
      
      // Listen to real-time order updates from Firestore
      _ordersSubscription = _orderRepository.streamUserOrders().listen(
        (ordersList) {
          print('📦 OrderController: Received ${ordersList.length} orders from stream');
          if (ordersList.isNotEmpty) {
            print('🔍 OrderController: First order ID: ${ordersList.first.id}, Status: ${ordersList.first.status}');
          }
          orders.value = ordersList;
          isLoading.value = false;
          print('✅ OrderController: UI updated with new orders');
        },
        onError: (error) {
          isLoading.value = false;
          print('❌ Order stream error: $error');
          Get.snackbar(
            'Error',
            'Failed to load orders. Please check your connection.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        },
      );
      print('✅ OrderController: Real-time listener active');
    } catch (e) {
      isLoading.value = false;
      print('❌ Error starting order listener: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize orders. Please restart the app.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Manual refresh (optional, since we have real-time updates)
  Future<void> refreshOrders() async {
    try {
      isLoading.value = true;
      final fetchedOrders = await _orderRepository.fetchAllItems();
      orders.value = fetchedOrders;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to refresh orders: $e');
      print('Order refresh error: $e');
    }
  }

  /// Add new order to Firebase (real-time listener will auto-update)
  Future<String?> addOrder(OrderModel order) async {
    try {
      final orderId = await _orderRepository.addItem(order);
      Get.snackbar('Success', 'Order placed successfully',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
      return orderId;
      // No need to manually update orders list, stream will handle it
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      print('Order creation error: $e');
      return null;
    }
  }

  /// Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Check if order can be cancelled
  bool canCancelOrder(OrderModel order) {
    return order.status.toLowerCase() == 'pending';
  }

  /// Cancel an order (only if pending)
  Future<bool> cancelOrder(OrderModel order, {bool showDialog = true}) async {
    try {
      // Check if order can be cancelled
      if (!canCancelOrder(order)) {
        Get.snackbar(
          'Cannot Cancel',
          'Order is already ${order.status}. Only pending orders can be cancelled.',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return false;
      }

      // Show confirmation dialog if requested
      if (showDialog) {
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
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        );

        if (confirmed != true) return false;
      }

      // Update order status to cancelled in Firestore
      await _orderRepository.updateSingleField(order.id, {'status': 'cancelled'});
      
      // No need to manually update orders list, real-time listener will handle it
      
      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel order: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      print('Order cancel error: $e');
      return false;
    }
  }
}