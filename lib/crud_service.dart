import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );

  // CREATE
  Future<void> addItems(String name) {
    return items.add({
      'name': name,
      'isFavorite': false,
      'createdAt': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateItems(String id, String name) {
    return items.doc(id).update({'name': name});
  }

  // ADD / REMOVE FAVORITE
  Future<void> updateFavorite(String id, bool isFavorite) {
    return items.doc(id).update({'isFavorite': isFavorite});
  }

  // GET FAVORITES
  Stream<QuerySnapshot> getFavoriteItems() {
    return items
        .where('isFavorite', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // DELETE
  Future<void> deleteItems(String id) {
    return items.doc(id).delete();
  }
}

