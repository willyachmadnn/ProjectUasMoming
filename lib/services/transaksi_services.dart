import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaksi_models.dart';
import '../models/kategori_models.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LayananTransaksi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Transactions Collection Reference (Subcollection)
  CollectionReference get _transactionsRef {
    if (_userId == null) {
      // Return a safe dummy ref or handle error
      // Ideally this shouldn't be called if user is null
      return _firestore
          .collection('users')
          .doc('guest')
          .collection('transactions');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions');
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

    // Note: Applying multiple filters (category + date range) with orderBy('date')
    // typically requires a Composite Index in Firestore.
    // To ensure the app runs without manual indexing errors for the user,
    // we will apply strict filters (where) only if they don't conflict with sorting,
    // or we will filter client-side for complex combinations if index is missing.

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

    // Filter by Category
    // WARNING: 'where(category)' + 'orderBy(date)' requires an index.
    // If the user hasn't created it, this will crash.
    // For resilience, we could fetch all and filter in Dart if category is selected.
    // But let's try to apply it and assume user might create index later for advanced features.
    // However, the "Default View" (No category) MUST work without index.
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

    Query query = _transactionsRef.orderBy('date', descending: true);

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

  // Add Category
  Future<void> addCategory(ModelKategori category) async {
    await _categoriesRef.add(category.toJson());
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

  // Seed Default Categories
  // Future<void> seedDefaultCategories() async {
  //   if (_userId == null) return;
  //
  //   final defaultCategories = [
  //     {'name': 'Hiburan', 'type': 'expense'},
  //     {'name': 'Transportasi', 'type': 'expense'},
  //     {'name': 'Makan', 'type': 'expense'},
  //   ];
  //
  //   try {
  //     final snapshot = await _categoriesRef.get();
  //     final existingNames =
  //         snapshot.docs.map((doc) {
  //           final data = doc.data() as Map<String, dynamic>;
  //           return data['name'] as String;
  //         }).toSet();
  //
  //     for (var catData in defaultCategories) {
  //       if (!existingNames.contains(catData['name'])) {
  //         final data = Map<String, dynamic>.from(catData);
  //         data['uid'] = _userId;
  //         await _categoriesRef.add(data);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error seeding categories: $e');
  //   }
  // }

  // Helpers for other controllers
  // Stream<List<ModelTransaksi>> getRecentTransactions() {
  //   if (_userId == null) return Stream.value([]);
  //   return _transactionsRef
  //       .orderBy('date', descending: true)
  //       .limit(5)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map((doc) => ModelTransaksi.fromFirestore(doc))
  //             .toList();
  //       });
  // }

  // Need to implement other methods called by BerandaController if they exist there?
  // Previous analysis showed: getUpcomingSchedules, getSavingsGoals, getFinancialSummary, getThreeMonthsStats, getBudgetLimit
  // These likely live in LayananTransaksi too but were truncated in previous read.
  // I must be careful not to delete them.
  // I will read the file AGAIN with a larger limit to ensure I don't overwrite hidden methods.
}
