import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../features/dashboard/ecommerce/models/banner_model.dart';
import '../../abstract/base_repository.dart';

class BannerRepository extends TBaseRepositoryController<BannerModel> {
  static BannerRepository get instance => Get.find();

  final String _collectionPath = 'Banners';

  @override
  Future<List<BannerModel>> fetchAllItems() async {
    final snapshot = await db
        .collection(_collectionPath)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => BannerModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<BannerModel> fetchSingleItem(String id) async {
    final snapshot = await db.collection(_collectionPath).doc(id).get();
    return BannerModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(BannerModel item) async {
    final docRef = await db.collection(_collectionPath).add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(BannerModel item) async {
    await db.collection(_collectionPath).doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await db.collection(_collectionPath).doc(id).update(json);
  }

  @override
  Future<void> deleteItem(BannerModel item) async {
    await db.collection(_collectionPath).doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    return db
        .collection(_collectionPath)
        .orderBy('order')
        .limit(limit);
  }

  @override
  BannerModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return BannerModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  /// Fetch only active banners
  Future<List<BannerModel>> fetchActiveBanners() async {
    final snapshot = await db
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => BannerModel.fromSnapshot(doc)).toList();
  }
}
