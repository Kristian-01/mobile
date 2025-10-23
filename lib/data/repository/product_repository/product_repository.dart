import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/products/models/product_model.dart';
import '../../abstract/base_repository.dart';

class ProductRepository extends TBaseRepositoryController<ProductModel> {
  static ProductRepository get instance => Get.find();

  final String _collectionPath = 'Products';

  @override
  Future<List<ProductModel>> fetchAllItems() async {
    final snapshot = await db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<ProductModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return ProductModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(ProductModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(ProductModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(ProductModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    return db.collection(_collectionPath).limit(limit);
  }

  @override
  ProductModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return ProductModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // Additional methods for product-specific queries
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isFeatured', isEqualTo: true)
        .limit(6)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }

  Future<List<ProductModel>> fetchPopularProducts() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isPopular', isEqualTo: true)
        .limit(8)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
  }
}