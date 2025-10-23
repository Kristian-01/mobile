import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/dashboard/ecommerce/models/category_model.dart';
import '../../abstract/base_repository.dart';

class CategoryRepository extends TBaseRepositoryController<CategoryModel> {
  static CategoryRepository get instance => Get.find();

  final String _collectionPath = 'categories';

  @override
  Future<List<CategoryModel>> fetchAllItems() async {
    final snapshot = await db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<CategoryModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return CategoryModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(CategoryModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(CategoryModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(CategoryModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    return db.collection(_collectionPath).limit(limit);
  }

  @override
  CategoryModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return CategoryModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  // Additional methods for category-specific queries
  Future<List<CategoryModel>> fetchFeaturedCategories() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isFeatured', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }

  Future<List<CategoryModel>> fetchSubCategories(String parentId) async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('parentId', isEqualTo: parentId)
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }
}