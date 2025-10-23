import 'package:cloud_firestore/cloud_firestore.dart';
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
}