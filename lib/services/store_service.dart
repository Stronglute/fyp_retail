import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_model.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Stores from Firestore
  Stream<List<Store>> getStores() {
    return _firestore.collection('stores').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Store.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Add New Store
  Future<void> addStore(Store store) async {
    await _firestore.collection('stores').add(store.toMap());
  }
}
