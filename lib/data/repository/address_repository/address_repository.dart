import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../personalization/models/address_model.dart';
import '../../abstract/base_repository.dart';
import '../authentication_repository/authentication_repository.dart';

class AddressRepository extends TBaseRepositoryController<AddressModel> {
  static AddressRepository get instance => Get.find();

  final String _collectionPath = 'UserAddresses';

  /// Get current user's address collection reference
  CollectionReference _getUserAddressCollection() {
    final userId = AuthenticationRepository.instance.getUserID;
    return db.collection('Users').doc(userId).collection(_collectionPath);
  }

  @override
  Future<List<AddressModel>> fetchAllItems() async {
    final snapshot = await _getUserAddressCollection().get();
    return snapshot.docs.map((doc) => AddressModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<AddressModel> fetchSingleItem(String id) async {
    final snapshot = await _getUserAddressCollection().doc(id).get();
    return AddressModel.fromSnapshot(snapshot);
  }

  @override
  Future<String> addItem(AddressModel item) async {
    final docRef = await _getUserAddressCollection().add(item.toJson());
    return docRef.id;
  }

  @override
  Future<void> updateItem(AddressModel item) async {
    await _getUserAddressCollection().doc(item.id).update(item.toJson());
  }

  @override
  Future<void> updateSingleField(String id, Map<String, dynamic> json) async {
    await _getUserAddressCollection().doc(id).update(json);
  }

  @override
  Future<void> deleteItem(AddressModel item) async {
    await _getUserAddressCollection().doc(item.id).delete();
  }

  @override
  Query getPaginatedQuery(int limit) {
    return _getUserAddressCollection().limit(limit);
  }

  @override
  AddressModel fromQueryDocSnapshot(QueryDocumentSnapshot<Object?> doc) {
    return AddressModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
  }

  /// Get the selected address (marked as selected)
  Future<AddressModel?> getSelectedAddress() async {
    final snapshot = await _getUserAddressCollection()
        .where('selectedAddress', isEqualTo: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return AddressModel.fromSnapshot(snapshot.docs.first);
  }

  /// Set an address as selected and unselect others
  Future<void> setSelectedAddress(String addressId) async {
    final batch = db.batch();
    
    // Get all addresses
    final snapshot = await _getUserAddressCollection().get();
    
    // Unselect all addresses
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'selectedAddress': false});
    }
    
    // Select the specified address
    final addressRef = _getUserAddressCollection().doc(addressId);
    batch.update(addressRef, {'selectedAddress': true});
    
    await batch.commit();
  }
}
