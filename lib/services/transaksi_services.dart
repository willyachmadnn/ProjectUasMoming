import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LayananTransaksi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Transactions Collection Reference (Root Collection)
  CollectionReference get _transactionsRef {
    return _firestore.collection('transactions');
  }

  // Categories Collection Reference (Subcollection)
  CollectionReference get _categoriesRef {
    if (_userId == null) {
      return _firestore
          .collection('users')
          .doc('guest')
          .collection('categories');
    }
    return _firestore.collection('users').doc(_userId).collection('categories');
  }

  // Get Transactions with Filters and Pagination
  Future<List<ModelTransaksi>> getTransactions({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? searchQuery,
    String? category,
    DateTime? month,
  }) async {
    if (_userId == null) return [];

    Query query = _transactionsRef.orderBy('date', descending: true);

    // Filter by Month
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

    // Pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    query = query.limit(limit);

    QuerySnapshot snapshot = await query.get();

    List<ModelTransaksi> transactions = snapshot.docs.map((doc) {
      return ModelTransaksi.fromFirestore(doc);
    }).toList();

    // Client-side search filtering
    if (searchQuery != null && searchQuery.isNotEmpty) {
      transactions = transactions
          .where(
            (t) =>
            t.description.toLowerCase().contains(searchQuery.toLowerCase()),
      )
          .toList();
    }

    return transactions;
  }

  // Get Transactions Stream (Realtime)
  Stream<QuerySnapshot> getTransactionsStream({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? category,
    DateTime? month,
  }) {
    if (_userId == null) {
      return const Stream.empty();
    }

    // Filter by User ID first
    Query query = _transactionsRef.where('uid', isEqualTo: _userId);

    // Then order by date
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

  // Add Transaction
  Future<void> addTransaction(ModelTransaksi transaction) async {
    if (_userId == null) {
      print("Warning: Adding transaction as Guest");
    }
    final data = transaction.toJson();
    data['uid'] = _userId; // Keep uid for redundancy/safety
    await _transactionsRef.add(data);
  }

  // Update Transaction
  Future<void> updateTransaction(ModelTransaksi transaction) async {
    await _transactionsRef.doc(transaction.id).update(transaction.toJson());
  }

  // Delete Transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsRef.doc(id).delete();
  }

  // --- CATEGORY METHODS ---

  // Add Category
  Future<void> addCategory(ModelKategori category) async {
    await _categoriesRef.add(category.toJson());
  }

  // Update Category (YANG PERLU DITAMBAHKAN)
  Future<void> updateCategory(ModelKategori category) async {
    await _categoriesRef.doc(category.id).update(category.toJson());
  }

  // Delete Category (YANG PERLU DITAMBAHKAN)
  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }

  // Get Categories Stream
  Stream<List<ModelKategori>> getCategories() {
    if (_userId == null) return Stream.value([]);
    // Subcollection doesn't need 'where uid'
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ModelKategori.fromFirestore(doc))
          .toList();
    });
  }
}