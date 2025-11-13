import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../features/orders/models/order_model.dart';
import '../../abstract/base_repository.dart';
import '../authentication_repository/authentication_repository.dart';

class OrderRepository extends TBaseRepositoryController<OrderModel> {
  static OrderRepository get instance => Get.find();

  final String _collectionPath = 'Orders';

  @override
  Future<List<OrderModel>> fetchAllItems() async {
    try {
      // Get current user's orders only
      final userId = AuthenticationRepository.instance.getUserID;
      
      // Simple query without orderBy to avoid index requirement
      final snapshot = await db
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      
      // Sort in code instead of in query
      final orders = snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate)); // Sort descending
      
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Future<OrderModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return OrderModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(OrderModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(OrderModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(OrderModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    final userId = AuthenticationRepository.instance.getUserID;
    return db
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .limit(limit);
  }

  @override
  OrderModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return OrderModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // Additional methods for order-specific queries
  Future<List<OrderModel>> fetchOrdersByStatus(String status) async {
    final userId = AuthenticationRepository.instance.getUserID;
    final snapshot = await db
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
  }

  /// Real-time stream listener for user's orders
  /// Returns a stream that emits whenever orders are added/updated/deleted
  Stream<List<OrderModel>> streamUserOrders() {
    final auth = FirebaseAuth.instance;
    print('🔥 OrderRepository: Subscribing to auth state changes for orders stream...');

    // Reactively rebuild the Firestore query when auth user changes
    return auth.userChanges().asyncExpand((user) {
      final uid = user?.uid ?? '';
      if (uid.isEmpty) {
        print('❌ OrderRepository: No authenticated user - returning empty orders stream');
        return Stream.value(<OrderModel>[]);
      }

      print('✅ OrderRepository: Listening to Orders for user: $uid');
      return db
          .collection(_collectionPath)
          .where('userId', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
        print('📡 OrderRepository: Firestore snapshot received with ${snapshot.docs.length} orders for $uid');
        final orders = snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return orders;
      });
    });
  }

  /// Real-time stream for a specific order by ID
  Stream<OrderModel?> streamOrderById(String orderId) {
    try {
      return db
          .collection(_collectionPath)
          .doc(orderId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          return OrderModel.fromSnapshot(snapshot);
        }
        return null;
      });
    } catch (e) {
      print('Error streaming order $orderId: $e');
      return Stream.value(null);
    }
  }
}