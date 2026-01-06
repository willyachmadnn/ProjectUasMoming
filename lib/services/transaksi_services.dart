import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LayananTransaksi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _transactionsRef {
    return _firestore.collection('transactions');
  }

  CollectionReference get _categoriesRef {
    if (_userId == null) {
      return _firestore
          .collection('users')
          .doc('guest')
          .collection('categories');
    }
    return _firestore.collection('users').doc(_userId).collection('categories');
  }

  Stream<QuerySnapshot> getTransactionsStream({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? category,
    DateTime? month,
  }) {
    // PERBAIKAN: Jangan return Stream.empty() jika user null.
    // Biarkan query jalan dengan uid null, hasilnya akan kosong dan loading berhenti.

    Query query = _transactionsRef.where('uid', isEqualTo: _userId);
    query = query.orderBy('date', descending: true);

    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      query = query
          .where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
      )
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
    }

    if (category != null && category != 'Semua Kategori') {
      query = query.where('category', isEqualTo: category);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    return query.snapshots();
  }

  Future<void> addTransaction(ModelTransaksi transaction) async {
    if (_userId == null) {
      throw Exception("User tidak ditemukan, mohon login ulang");
    }
    final data = transaction.toJson();
    data['uid'] = _userId;
    await _transactionsRef.add(data);
  }

  Future<void> updateTransaction(ModelTransaksi transaction) async {
    await _transactionsRef.doc(transaction.id).update(transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsRef.doc(id).delete();
  }

  Future<void> addCategory(ModelKategori category) async {
    await _categoriesRef.add(category.toJson());
  }

  Future<void> updateCategory(ModelKategori category) async {
    await _categoriesRef.doc(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }

  Stream<List<ModelKategori>> getCategories() {
    if (_userId == null) return Stream.value([]);
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ModelKategori.fromFirestore(doc))
          .toList();
    });
  }
}